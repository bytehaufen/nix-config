-- Run from the repository root: nvim --headless -u NONE -l <this-file>
-- All LSP interactions are mocked; this test never starts a language server.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
local root = vim.fn.tempname()
local function write(path, text)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(text, "\n"), path)
end
local function json(path, value)
	write(path, vim.json.encode(value))
end
local function fails(fn, message)
	local ok, err = pcall(fn)
	assert(not ok and tostring(err):find(message, 1, true), tostring(err))
end
local function open(path, ft)
	vim.cmd.edit(vim.fn.fnameescape(path))
	vim.bo.filetype = ft
	return vim.api.nvim_get_current_buf()
end
local repo = root .. "/checkout"
for _, name in ipairs({ "api", "nested/client", "excluded", "api/nested" }) do
	write(repo .. "/" .. name .. "/.project", "<projectDescription/>")
	write(repo .. "/" .. name .. "/src/Example.java", "class Example {}")
end
write(repo .. "/fixture.target", '<target name="test"/>')
local selection = { projects = { "api", "nested/client" }, targetPlatform = "fixture.target" }
json(repo .. "/javaConfig.json", selection)
local java = vim.fn.resolve(vim.fn.exepath("java"))
local tools = {
	jdtls = vim.fn.exepath("true"),
	flock = vim.fn.exepath("true"),
	javaHome = vim.fs.dirname(vim.fs.dirname(java)),
	bundles = root .. "/bundles.json",
}
write(root .. "/fake.jar", "fixture")
json(tools.bundles, { root .. "/fake.jar" })
vim.env.XDG_CONFIG_HOME = root .. "/config"
vim.env.XDG_CACHE_HOME = root .. "/cache"
vim.env.XDG_STATE_HOME = root .. "/state"
vim.env.PDE_JAVA_23_HOME = nil
json(root .. "/config/nvim-pde/tools.json", tools)

local starts, attached, clients, requests = {}, {}, {}, {}
local notifications, logged = {}, {}
vim.notify = function(message, level)
	notifications[#notifications + 1] = { message = message, level = level }
end
local original_log_handler = vim.lsp.handlers["window/logMessage"]
vim.lsp.handlers["window/logMessage"] = function(_, result)
	logged[#logged + 1] = result
end
vim.lsp.get_client_by_id = function(id)
	return clients[id]
end
vim.lsp.buf_attach_client = function(buf, id)
	attached[buf] = id
end
package.preload.jdtls = function()
	return {
		organize_imports = function() end,
		extract_variable = function() end,
		extract_constant = function() end,
		start_or_attach = function(config, _, opts)
			starts[#starts + 1] = { config = config, buf = opts.bufnr }
			local id = #starts
			clients[id] = {
				initialized = true,
				handlers = vim.deepcopy(config.handlers),
				server_capabilities = { executeCommandProvider = { commands = { "java.pde.reloadTargetPlatform" } } },
				stop = function()
					clients[id] = nil
					config.on_exit(0, 0)
				end,
				request = function(_, method, params, callback)
					requests[#requests + 1] = { method = method, params = params }
					callback(nil)
					return true, #requests
				end,
			}
			return id
		end,
	}
end
local pde = require("config.pde")
pde.setup()
local api = open(repo .. "/api/src/Example.java", "java")
local client = open(repo .. "/nested/client/src/Example.java", "java")
assert(#starts == 0, "Opening a Java buffer must never start a server")
assert(pde.root() == repo, "Nested .project must not become the LSP root")
local ws = pde.workspace(repo)
selection.targetPlatform = repo .. "/fixture.target"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "targetPlatform must be relative")
selection.targetPlatform = "fixture.target"
json(repo .. "/javaConfig.json", selection)
local config, state = pde.build_config(ws, tools)
assert(config.root_dir == repo and not state:find(repo, 1, true))
assert(vim.tbl_contains(config.cmd, "--jvm-arg=-Xmx6g"))
assert(vim.deep_equal(config.init_options.settings, config.settings), "Import controls must be present in initialize")
assert(vim.deep_equal(config.settings.java.import.exclusions, { "**" }))
assert(vim.deep_equal(config.settings.java.project.resourceFilters, {}))

open(repo .. "/javaConfig.json", "json")
pde.start()
assert(#starts == 1 and (starts[1].buf == api or starts[1].buf == client), "Start from config must pass a Java buffer")
pde.start()
assert(#starts == 1 and attached[api] == 1 and attached[client] == 1, "Reuse one client across selected projects")
local log_handler = starts[1].config.handlers["window/logMessage"]
assert(vim.lsp.handlers["window/logMessage"] ~= log_handler, "PDE must not replace other clients' global handler")
local notification_count = #notifications
log_handler(nil, { type = 2, message = "Warning only" }, { client_id = 1 })
assert(#notifications == notification_count, "Warnings must retain their normal log behavior")
for _ = 1, 100 do
	log_handler(
		nil,
		{ type = 1, message = "Problems loading repositories\nJAXP00010003: jdk.xml.maxGeneralEntitySizeLimit" },
		{ client_id = 1 }
	)
end
assert(#logged == 101, "Full error messages must still reach the standard log handler")
assert(vim.wait(1500, function()
	return #notifications > notification_count
end))
assert(#notifications == notification_count + 1, "An error burst must produce one notification")
local alert = notifications[#notifications]
assert(alert.level == vim.log.levels.ERROR and alert.message:find("100 error(s)", 1, true))
assert(alert.message:find("XML parser limit", 1, true) and alert.message:find(":JdtShowLogs", 1, true))
local excluded = open(repo .. "/excluded/src/Example.java", "java")
assert(not attached[excluded] and #starts == 1)
local nested = open(repo .. "/api/nested/src/Example.java", "java")
assert(not attached[nested], "Nested unlisted project must not attach")
open(repo .. "/fixture.target", "xml")
pde.reload_target("")
assert(requests[1].method == "workspace/executeCommand")
assert(requests[1].params.command == "java.pde.reloadTargetPlatform")
assert(vim.deep_equal(requests[1].params.arguments, { vim.uri_from_fname(repo .. "/fixture.target") }))
write(repo .. "/with spaces.target", '<target name="spaces"/>')
vim.cmd("PdeReloadTarget " .. vim.fn.fnameescape("with spaces.target"))
assert(vim.deep_equal(requests[2].params.arguments, { vim.uri_from_fname(repo .. "/with spaces.target") }))
fails(function()
	pde.reload_target("missing.target")
end, "Target file not found")
clients[1].server_capabilities.executeCommandProvider.commands = {}
fails(function()
	pde.reload_target("")
end, "PDE reload command unavailable")

selection.projects = { "api" }
json(repo .. "/javaConfig.json", selection)
local _, reduced = pde.build_config(pde.workspace(repo), tools)
assert(reduced ~= state, "Pruned selections must not reuse a workspace containing old projects")
pde.restart()
assert(vim.wait(2000, function()
	return #starts == 2
end))
assert(starts[2].config.cmd[#starts[2].config.cmd] == reduced .. "/workspace")
starts[2].config.handlers["window/logMessage"](nil, { type = 1, message = "Late error" }, { client_id = 2 })
pde.stop()
vim.wait(50, function()
	return clients[2] == nil
end)
vim.wait(50)
notification_count = #notifications
vim.wait(1100, function()
	return false
end)
assert(#notifications == notification_count, "A stopped client must not emit queued error notifications")
fails(function()
	pde.reload_target("")
end, "Start PDE")
assert(#starts == 2, "Stopping must not restart the server")

-- A checkout profile must survive initialization and control format requests,
-- without changing unrelated buffers or requiring another server per project.
write(
	repo .. "/team style.xml",
	[[<profiles><profile name="Other">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="space"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="2"/>
</profile><profile name="Team">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="tab"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
</profile></profiles>]]
)
selection.formatter = { path = "./team style.xml", profile = "Team" }
json(repo .. "/javaConfig.json", selection)
local formatted = pde.build_config(pde.workspace(repo), tools)
assert(formatted.settings.java.format.settings, "The configured formatter must reach JDT LS")
assert(formatted.settings.java.format.settings.url == vim.uri_from_fname(repo .. "/team style.xml"))
assert(formatted.init_options.settings.java.format.settings.profile == "Team")
assert(formatted.init_options.settings.java.format.insertSpaces == false)
assert(formatted.init_options.settings.java.format.tabSize == 4)
selection.formatter.profile = "Missing"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.build_config(pde.workspace(repo), tools)
end, "expected exactly one profile")
selection.formatter.profile = "Other"
json(repo .. "/javaConfig.json", selection)
local other = pde.build_config(pde.workspace(repo), tools)
assert(other.settings.java.format.insertSpaces and other.settings.java.format.tabSize == 2)
selection.formatter.profile = "Team"
json(repo .. "/javaConfig.json", selection)
write(repo .. "/broken.xml", "<profiles><profile>")
local broken = pde.workspace(repo)
broken.formatter.url = vim.uri_from_fname(repo .. "/broken.xml")
fails(function()
	pde.build_config(broken, tools)
end, "Cannot load formatter profile")
vim.api.nvim_set_current_buf(api)
vim.bo[api].expandtab, vim.bo[api].shiftwidth, vim.bo[api].tabstop = true, 2, 2
vim.bo[excluded].expandtab, vim.bo[excluded].shiftwidth = true, 2
pde.start()
local active = starts[3].config
local pending = {}
clients[3].request = function(_, _, params, callback, buf)
	assert(params.command == "java.project.getSettings")
	pending[#pending + 1] = { callback = callback, buf = buf }
	return true, #pending
end
active.on_attach(clients[3], api)
active.on_init(clients[3])
assert(#pending == 0, "Wait for project import before reading formatter preferences")
clients[3].handlers["language/status"](nil, { type = "ServiceReady", message = "Ready" })
assert(#pending == 1 and pending[1].buf == api)
local prefs = {
	["org.eclipse.jdt.core.formatter.tabulation.char"] = "tab",
	["org.eclipse.jdt.core.formatter.tabulation.size"] = "4",
	["org.eclipse.jdt.core.formatter.lineSplit"] = "140",
}
pending[1].callback(nil, prefs)
assert(not vim.bo[api].expandtab and vim.bo[api].tabstop == 4 and vim.bo[api].shiftwidth == 4)
assert(vim.bo[api].textwidth == 140 and vim.bo[api].softtabstop == 4)
local params = vim.lsp.util.make_formatting_params()
assert(
	params.options.insertSpaces == false and params.options.tabSize == 4,
	"Manual LSP formatting must use the selected profile's indentation"
)
assert(vim.bo[excluded].expandtab and vim.bo[excluded].shiftwidth == 2)
active.on_attach(clients[3], api)
assert(#pending == 2, "Buffers attached after import also need formatter preferences")
pde.stop()
vim.wait(50)
vim.bo[api].shiftwidth = 7
pending[2].callback(nil, prefs)
assert(vim.bo[api].shiftwidth == 7, "Ignore stale replies after stopping")
selection.formatter.path = "missing.xml"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "Formatter file not found")
selection.formatter = { path = "./team style.xml", profile = "" }
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "formatter.profile")
selection.formatter = nil

write(repo .. "/oomph.target", '<target><locations><location type="Targlet"/></locations></target>')
selection.targetPlatform = "oomph.target"
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "Oomph targlets")
selection.targetPlatform = "fixture.target"
selection.projects = { "../outside" }
json(repo .. "/javaConfig.json", selection)
fails(function()
	pde.workspace(repo)
end, "inside the workspace")
write(repo .. "/javaConfig.json", "not json")
fails(function()
	pde.workspace(repo)
end, "Cannot read JSON")
vim.lsp.handlers["window/logMessage"] = original_log_handler
print(
	"PDE checks passed: manual lifecycle, root selection, imports, reload, formatter, runtime/config validation, error notifications"
)
vim.cmd.quitall()
