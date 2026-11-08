-- Opt-in integration test: real JavaFX source navigation and SDK upgrades in a disposable PDE workspace.
-- Requires JavaFX-enabled PDE_TOOLS_JSON from the project dev shell and installed nvim-jdtls.
assert(
	vim.env.PDE_TOOLS_JSON and vim.env.PDE_TOOLS_JSON ~= "",
	"Run from the JavaFX project dev shell with PDE_TOOLS_JSON"
)
local task = assert(vim.uv.fs_mkdtemp("/tmp/pde-javafx.XXXXXX"))
vim.env.XDG_CACHE_HOME = task .. "/cache"
vim.env.XDG_STATE_HOME = task .. "/state"
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-jdtls")
vim.cmd.runtime("plugin/jdtls.lua")
local function write(path, content)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(content, "\n"), path)
end
local function read(path)
	return table.concat(vim.fn.readfile(path, "b"), "\n")
end
local repo = task .. "/fixture"
local project = repo .. "/example.javafx"
write(
	project .. "/.project",
	[[<projectDescription><name>example.javafx</name><buildSpec>
<buildCommand><name>org.eclipse.jdt.core.javabuilder</name></buildCommand>
<buildCommand><name>org.eclipse.pde.ManifestBuilder</name></buildCommand></buildSpec><natures>
<nature>org.eclipse.pde.PluginNature</nature><nature>org.eclipse.jdt.core.javanature</nature>
</natures></projectDescription>]]
)
write(
	project .. "/.classpath",
	[[<classpath><classpathentry kind="src" path="src"/>
<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-23"/>
<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
<classpathentry kind="output" path="bin"/></classpath>]]
)
write(
	project .. "/META-INF/MANIFEST.MF",
	[[Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-SymbolicName: example.javafx
Bundle-Version: 1.0.0
Bundle-RequiredExecutionEnvironment: JavaSE-23
]]
)
write(
	project .. "/.settings/org.eclipse.jdt.core.prefs",
	[[eclipse.preferences.version=1
org.eclipse.jdt.core.compiler.compliance=23
org.eclipse.jdt.core.compiler.source=23
org.eclipse.jdt.core.compiler.codegen.targetPlatform=23]]
)
write(repo .. "/fixture.target", '<target name="JavaFX sources"><locations/></target>')
write(
	repo .. "/javaConfig.json",
	vim.json.encode({ projects = { "example.javafx" }, targetPlatform = "fixture.target" })
)
write(
	project .. "/src/Probe.java",
	[[import javafx.scene.control.Button;
import javafx.fxml.FXMLLoader;
public class Probe { Button button; FXMLLoader loader; }]]
)
local metadata = {}
for _, path in ipairs({ ".project", ".classpath", "META-INF/MANIFEST.MF" }) do
	metadata[path] = read(project .. "/" .. path)
end
local errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
	if level == vim.log.levels.ERROR then
		errors[#errors + 1] = tostring(message)
	end
	notify(message, level, opts)
end
local function current()
	for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
		if client.config._pde and client.config._pde.ready then
			return client
		end
	end
end
local function request(client, method, params, buf)
	local response = assert(client:request_sync(method, params, 30000, buf), method .. " timed out")
	assert(not response.err, vim.inspect(response.err))
	return response.result
end
local function ready(buf, previous)
	assert(
		vim.wait(60000, function()
			local client = current()
			return client and client.id ~= previous and vim.lsp.buf_is_attached(buf, client.id)
		end, 50),
		"PDE did not become ready"
	)
	return current()
end
local function navigate(client, buf, symbol, line_nr, package, expected_sources)
	vim.api.nvim_set_current_buf(buf)
	local line = vim.api.nvim_buf_get_lines(buf, line_nr, line_nr + 1, false)[1]
	local locations = request(client, "textDocument/definition", {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
		position = { line = line_nr, character = assert(line:find(symbol, 1, true)) - 1 },
	}, buf)
	assert(type(locations) == "table" and locations[1], symbol .. " has no definition")
	local location = locations[1]
	assert(location.uri:find("/" .. package .. "/" .. symbol .. ".java", 1, true), "Wrong definition: " .. location.uri)
	local attachment = request(client, "workspace/executeCommand", {
		command = "java.project.resolveSourceAttachment",
		arguments = { vim.json.encode({ classFileUri = location.uri }) },
	}, buf)
	assert(not attachment.errorMessage, vim.inspect(attachment))
	local sources = attachment.attributes.sourceAttachmentPath
	assert(sources and vim.fn.filereadable(sources) == 1, "JavaFX sources are not attached")
	if expected_sources then
		assert(sources == expected_sources, "Native restart kept the old SDK source attachment: " .. sources)
	end
	assert(vim.lsp.util.show_document(location, client.offset_encoding, { focus = true }), "Cannot open JavaFX source")
	local library_buf = vim.api.nvim_get_current_buf()
	local content = table.concat(vim.api.nvim_buf_get_lines(library_buf, 0, -1, false), "\n")
	assert(
		content:find("package " .. package .. ";", 1, true) and content:find("class " .. symbol, 1, true),
		"Wrong JavaFX source"
	)
	assert(content:find("Copyright", 1, true), "Expected real JavaFX source, not a decompiler stub")
	assert(not vim.bo[library_buf].modifiable, "Library source should not be editable")
	return sources
end
print("Test state: " .. task)
local ok, failure = xpcall(function()
	vim.cmd.cd(repo)
	require("config.pde").setup()
	vim.cmd.edit(project .. "/src/Probe.java")
	vim.bo.filetype = "java"
	local buf = vim.api.nvim_get_current_buf()
	local client = ready(buf)
	local sources = navigate(client, buf, "Button", 0, "javafx.scene.control")
	navigate(client, buf, "FXMLLoader", 1, "javafx.fxml")
	-- A new Nix SDK path must replace cached PDE entries without rewriting .classpath.
	local sdk = task .. "/updated-sdk"
	vim.fn.mkdir(sdk .. "/lib", "p")
	assert(vim.uv.fs_copyfile(sources, sdk .. "/src.zip"))
	for name, kind in vim.fs.dir(vim.fs.dirname(sources) .. "/lib") do
		if kind == "file" and name:match("%.jar$") then
			assert(vim.uv.fs_copyfile(vim.fs.dirname(sources) .. "/lib/" .. name, sdk .. "/lib/" .. name))
		end
	end
	local tools = vim.json.decode(read(assert(vim.env.PDE_TOOLS_JSON)))
	local launcher = task .. "/updated-jdtls"
	write(
		launcher,
		"#!/bin/sh\nexec "
			.. vim.fn.shellescape(tools.jdtls)
			.. ' "$@" '
			.. vim.fn.shellescape("--jvm-arg=-Dcoside.javafx.sdk=" .. sdk .. "/lib")
	)
	assert(vim.uv.fs_chmod(launcher, 493))
	tools.jdtls = launcher
	write(task .. "/updated-tools.json", vim.json.encode(tools))
	vim.env.PDE_TOOLS_JSON = task .. "/updated-tools.json"
	vim.api.nvim_set_current_buf(buf)
	local previous = client.id
	vim.cmd("lsp restart jdtls")
	client = ready(buf, previous)
	navigate(client, buf, "Button", 0, "javafx.scene.control", sdk .. "/src.zip")
	navigate(client, buf, "FXMLLoader", 1, "javafx.fxml", sdk .. "/src.zip")
	for path, expected in pairs(metadata) do
		assert(read(project .. "/" .. path) == expected, "Shared project metadata changed: " .. path)
	end
	assert(#errors == 0, table.concat(errors, "\n"))
	print("PASS: real JavaFX source buffers, SDK upgrade through native restart, unchanged Eclipse metadata")
end, debug.traceback)
vim.lsp.enable("jdtls", false)
local stopped = vim.wait(15000, function()
	return #vim.lsp.get_clients({ name = "jdtls", _uninitialized = true }) == 0
end, 50)
if not stopped then
	for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls", _uninitialized = true })) do
		client:stop(true)
	end
end
if not ok or not stopped then
	print(failure or "Java server did not stop")
	vim.cmd("cquit 1")
end
vim.fn.delete(task, "rf")
vim.cmd("qa!")
