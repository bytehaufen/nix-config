-- Opt-in integration test: starts real JDT LS in a disposable one-project workspace.
-- Requires the activated nvim-pde/tools.json and installed nvim-jdtls.
-- PDE_TEST_FORMATTER / PDE_TEST_PROFILE optionally select an existing XML profile.
local task = assert(vim.uv.fs_mkdtemp("/tmp/pde-formatter.XXXXXX"))
vim.env.XDG_CACHE_HOME = task .. "/cache"
vim.env.XDG_STATE_HOME = task .. "/state"
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-jdtls")
vim.cmd.runtime("plugin/jdtls.lua")
local function write(path, content)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(content, "\n"), path)
end
local repo = task .. "/fixture"
local project = repo .. "/example.format"
write(
	project .. "/.project",
	[[<projectDescription><name>example.format</name><buildSpec>
<buildCommand><name>org.eclipse.jdt.core.javabuilder</name></buildCommand>
<buildCommand><name>org.eclipse.pde.ManifestBuilder</name></buildCommand></buildSpec><natures>
<nature>org.eclipse.pde.PluginNature</nature><nature>org.eclipse.jdt.core.javanature</nature>
</natures></projectDescription>]]
)
write(
	project .. "/.classpath",
	[[<classpath><classpathentry kind="src" path="src"/>
<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-25"/>
<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
<classpathentry kind="output" path="bin"/></classpath>]]
)
write(
	project .. "/META-INF/MANIFEST.MF",
	[[Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: Formatter test
Bundle-SymbolicName: example.format
Bundle-Version: 1.0.0
Bundle-RequiredExecutionEnvironment: JavaSE-25
]]
)
write(repo .. "/fixture.target", '<target name="formatter"><locations/></target>')
write(
	repo .. "/team style.xml",
	[[<?xml version="1.0" encoding="UTF-8"?>
<profiles version="23"><profile kind="CodeFormatterProfile" name="Team" version="23">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="tab"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
<setting id="org.eclipse.jdt.core.formatter.lineSplit" value="140"/>
<setting id="org.eclipse.jdt.core.formatter.brace_position_for_method_declaration" value="next_line"/>
</profile></profiles>]]
)
write(
	repo .. "/javaConfig.json",
	vim.json.encode({
		projects = { "example.format" },
		targetPlatform = "fixture.target",
		formatter = {
			path = vim.env.PDE_TEST_FORMATTER or "./team style.xml",
			profile = vim.env.PDE_TEST_PROFILE or "Team",
		},
	})
)
write(project .. "/src/Example.java", "public class Example { public int sum(int a,int b){return a+b;} }")
write(project .. "/src/Bootstrap.java", "class Bootstrap {}")
local pde = require("config.pde")
vim.lsp.log.set_level("debug")
print("Test state: " .. task)
pde.setup()
vim.cmd.edit(project .. "/src/Bootstrap.java")
vim.bo.filetype = "java"
local bootstrap = vim.api.nvim_get_current_buf()
local client
local ok, failure = xpcall(function()
	assert(
		vim.wait(1000, function()
			client = vim.lsp.get_clients({ name = "jdtls", _uninitialized = true })[1]
			return client ~= nil
		end),
		"Opening Java must start PDE automatically"
	)
	vim.cmd.edit(project .. "/src/Example.java")
	vim.bo.filetype = "java"
	vim.bo.expandtab, vim.bo.shiftwidth, vim.bo.tabstop = true, 2, 2
	vim.api.nvim_buf_delete(bootstrap, { force = true })
	assert(
		vim.wait(60000, function()
			client = vim.lsp.get_clients({ name = "jdtls" })[1]
			return client and not vim.bo.expandtab and vim.bo.shiftwidth == 4 and vim.bo.textwidth == 140
		end, 100),
		"Profile/indentation not applied after import"
	)
	-- Same standard LSP formatting parameters used by manual LazyVim formatting.
	local response, err =
		client:request_sync("textDocument/formatting", vim.lsp.util.make_formatting_params(), 20000, 0)
	assert(response and not response.err and #response.result > 0, vim.inspect(err or response))
	vim.lsp.util.apply_text_edits(response.result, vim.api.nvim_get_current_buf(), client.offset_encoding)
	local result = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	assert(result:find("\n\tpublic int sum(int a, int b)", 1, true), result)
	assert(result:find("\n\t\treturn a + b;", 1, true), result)
	if not vim.env.PDE_TEST_FORMATTER then
		assert(result:find("sum(int a, int b)\n\t{", 1, true), "XML brace rule was ignored: " .. result)
	end
	local previous_id = client.id
	vim.cmd("lsp restart jdtls")
	assert(
		vim.wait(60000, function()
			client = vim.lsp.get_clients({ name = "jdtls" })[1]
			return client and client.id ~= previous_id and client.config._pde.ready
		end, 100),
		"Native restart must release the workspace lock and initialize a replacement"
	)
	local formatted_again =
		client:request_sync("textDocument/formatting", vim.lsp.util.make_formatting_params(), 20000, 0)
	assert(formatted_again and not formatted_again.err, vim.inspect(formatted_again))
	print("PASS: real PDE XML formatter, wiped startup buffer, native restart and workspace-lock reuse")
end, debug.traceback)
vim.cmd("lsp disable jdtls")
if
	not vim.wait(15000, function()
		return #vim.lsp.get_clients({ name = "jdtls", _uninitialized = true }) == 0
	end, 100) and client
then
	client:stop(true)
end
if not ok then
	print(failure)
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
