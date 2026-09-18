-- Exercise real Neovim clients and :lsp commands with an in-process transport.
-- Requires installed nvim-jdtls and blink.cmp, but never starts Java or another subprocess.
local task = vim.fn.tempname()
vim.env.XDG_CACHE_HOME, vim.env.XDG_STATE_HOME = task .. "/cache", task .. "/state"
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-jdtls")
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/blink.cmp")
local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
vim.cmd.runtime("plugin/jdtls.lua")
local function write(path, text)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(text, "\n"), path)
end
local function json(path, value)
	write(path, vim.json.encode(value))
end
local function open(path, ft)
	vim.cmd.edit(vim.fn.fnameescape(path))
	vim.bo.filetype = ft
	return vim.api.nvim_get_current_buf()
end
local function wait(predicate, message)
	assert(vim.wait(2000, predicate, 10), message)
end
local function clients()
	return vim.lsp.get_clients({ name = "jdtls", _uninitialized = true })
end
local function current()
	return vim.lsp.get_clients({ name = "jdtls" })[1]
end
local repo = task .. "/checkout"
for _, project in ipairs({ "api", "client", "excluded", "api/nested" }) do
	write(repo .. "/" .. project .. "/.project", "<projectDescription/>")
	write(repo .. "/" .. project .. "/Example.java", "class Example {}")
end
write(repo .. "/fixture.target", '<target name="test"/>')
write(
	repo .. "/team.xml",
	[[<profiles><profile name="Team">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="tab"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
</profile><profile name="Other">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="space"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="2"/>
</profile></profiles>]]
)
local selection = {
	projects = { "api", "client" },
	targetPlatform = "fixture.target",
	formatter = { path = "team.xml", profile = "Team" },
}
json(repo .. "/javaConfig.json", selection)
local java = vim.fn.resolve(vim.fn.exepath("java"))
write(task .. "/fake.jar", "fixture")
json(task .. "/bundles.json", { task .. "/fake.jar" })
vim.env.XDG_CONFIG_HOME = task .. "/config"
json(task .. "/config/nvim-pde/tools.json", {
	jdtls = vim.fn.exepath("true"),
	flock = vim.fn.exepath("true"),
	javaHome = vim.fs.dirname(vim.fs.dirname(java)),
	bundles = task .. "/bundles.json",
})
local transports, notices = {}, {}
vim.notify = function(message)
	notices[#notices + 1] = message
end
vim.lsp.rpc.start = function(cmd, dispatchers, opts)
	local transport = { cmd = vim.deepcopy(cmd), cwd = opts.cwd, reloads = {} }
	transports[#transports + 1] = transport
	local sequence = 0
	local function finish()
		if transport.closed then
			return
		end
		transport.closed = true
		vim.schedule(function()
			dispatchers.on_exit(0, 0)
		end)
	end
	return {
		is_closing = function()
			return transport.closed or false
		end,
		terminate = finish,
		notify = function(method)
			if method == "initialized" then
				vim.defer_fn(function()
					if not transport.closed then
						dispatchers.notification("language/status", { type = "ServiceReady", message = "Ready" })
					end
				end, 30)
			elseif method == "exit" then
				finish()
			end
			return true
		end,
		request = function(method, params, callback)
			sequence = sequence + 1
			local result
			if method == "initialize" then
				transport.initialize = vim.deepcopy(params)
				result = {
					capabilities = {
						textDocumentSync = 1,
						documentFormattingProvider = true,
						executeCommandProvider = {
							commands = { "java.project.getSettings", "java.pde.reloadTargetPlatform" },
						},
					},
				}
			elseif method == "workspace/executeCommand" then
				if params.command == "java.pde.reloadTargetPlatform" then
					transport.reloads[#transport.reloads + 1] = params.arguments[1]
				else
					local format = transport.initialize.initializationOptions.settings.java.format
					result = {
						["org.eclipse.jdt.core.formatter.tabulation.char"] = format.insertSpaces and "space" or "tab",
						["org.eclipse.jdt.core.formatter.tabulation.size"] = tostring(format.tabSize),
						["org.eclipse.jdt.core.formatter.lineSplit"] = "140",
					}
				end
			end
			vim.schedule(function()
				callback(nil, result)
			end)
			return true, sequence
		end,
	}
end
local pde = require("config.pde")
open(task .. "/notes.txt", "text")
pde.setup()
local capabilities = vim.lsp.config.jdtls.capabilities
local expected_completion = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities().textDocument.completion,
	blink_capabilities.textDocument.completion
)
assert(vim.deep_equal(capabilities.textDocument.completion, expected_completion))
local kinds = capabilities.textDocument.codeAction.codeActionLiteralSupport.codeActionKind.valueSet
for _, kind in ipairs({
	"quickfix",
	"source.generate.toString",
	"source.generate.hashCodeEquals",
	"source.organizeImports",
}) do
	assert(vim.tbl_contains(kinds, kind), "Missing code action capability: " .. kind)
end
vim.wait(50)
assert(#transports == 0 and #notices == 0, "Non-Java startup must neither start JDTLS nor report errors")
assert(vim.lsp.is_enabled("jdtls"), "PDE must register with the native LSP lifecycle")
assert(vim.fn.exists(":PdeStart") == 0 and vim.fn.exists(":PdeRestart") == 0 and vim.fn.exists(":PdeStop") == 0)
open(task .. "/Outside.java", "java")
local excluded = open(repo .. "/excluded/Example.java", "java")
local nested = open(repo .. "/api/nested/Example.java", "java")
vim.wait(50)
assert(#transports == 0 and #notices == 0)
local api = open(repo .. "/api/Example.java", "java")
local dep = open(repo .. "/client/Example.java", "java")
wait(function()
	return current() and current().attached_buffers[api] and current().attached_buffers[dep]
end, "Selected projects must share a client")
assert(#transports == 1 and not current().attached_buffers[excluded] and not current().attached_buffers[nested])
wait(function()
	return not vim.bo[api].expandtab and vim.bo[api].textwidth == 140
end, "Formatter must apply after readiness")
local first = current()
local old_data = transports[1].cmd[#transports[1].cmd]
assert(transports[1].initialize.initializationOptions.settings.java.autobuild.enabled == false)
assert(vim.deep_equal(transports[1].initialize.initializationOptions.settings.java.import.exclusions, { "**" }))
vim.wait(50)
local prompts = 0
vim.ui.select = function()
	prompts = prompts + 1
end
vim.cmd.JdtWipeDataAndRestart()
assert(prompts == 0 and #transports == 1 and not transports[1].closed)
write(old_data .. "/.metadata/.log", "PDE log fixture")
vim.cmd.JdtShowLogs()
assert(vim.fn.bufnr(old_data .. "/.metadata/.log") >= 0, "Logs command must resolve the dynamic launcher workspace")
-- Native restart reuses Client.config: our dynamic launcher must reread JSON.
selection.projects = { "api" }
selection.formatter.profile = "Other"
json(repo .. "/javaConfig.json", selection)
open(repo .. "/javaConfig.json", "json")
vim.cmd("lsp restart jdtls")
wait(function()
	return current() and current().id ~= first.id and current().attached_buffers[api]
end, "Native restart must replace and reconnect the server")
assert(#transports == 2 and transports[1].closed)
assert(transports[2].cmd[#transports[2].cmd] ~= old_data, "Removed projects require a fresh workspace generation")
assert(not current().attached_buffers[dep], "Native restart must not reattach removed projects")
assert(transports[2].initialize.initializationOptions.settings.java.format.settings.profile == "Other")
wait(function()
	return vim.bo[api].expandtab and vim.bo[api].shiftwidth == 2
end, "Restart must reload formatter preferences")
vim.cmd("PdeReloadTarget " .. vim.fn.fnameescape(repo .. "/fixture.target"))
assert(transports[2].reloads[1] == vim.uri_from_fname(repo .. "/fixture.target"))
-- Unnamed :lsp restart operates on the current buffer's client.
vim.api.nvim_set_current_buf(api)
local second = current()
vim.cmd("lsp restart")
wait(function()
	return current() and current().id ~= second.id and current().attached_buffers[api]
end, "Buffer-local native restart must work")
assert(#transports == 3 and transports[3].cmd[#transports[3].cmd] == transports[2].cmd[#transports[2].cmd])
vim.cmd("lsp disable jdtls")
wait(function()
	return #clients() == 0
end, "Disable must stop the server")
open(repo .. "/api/Later.java", "java")
vim.wait(50)
assert(#transports == 3 and not vim.lsp.is_enabled("jdtls"), "Disable must suppress automatic startup")
vim.cmd("lsp enable jdtls")
wait(function()
	return current() ~= nil
end, "Enable must restart for already-open Java buffers")
assert(#transports == 4)
vim.cmd("lsp stop jdtls")
wait(function()
	return #clients() == 0
end, "Stop must terminate the current client")
assert(vim.lsp.is_enabled("jdtls"), "Stop must preserve native enable/disable semantics")
open(repo .. "/api/AfterStop.java", "java")
wait(function()
	return current() ~= nil
end, "An enabled configuration may start on another Java file")
assert(#transports == 5)
vim.cmd("lsp disable jdtls")
wait(function()
	return #clients() == 0
end, "All test clients must stop")
print("PASS: native enable/disable/stop/restart, selection reload, cache generation, formatter, target reload")
vim.cmd("qa!")
