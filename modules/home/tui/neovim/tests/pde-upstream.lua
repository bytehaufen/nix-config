-- Real nvim-jdtls wrappers/commands, mocked transport: never starts Java.
-- Requires the installed, pinned nvim-jdtls plugin.
local task = vim.fn.tempname()
vim.env.XDG_CACHE_HOME = task .. "/cache"
vim.env.XDG_STATE_HOME = task .. "/state"
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim")
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-jdtls")
local function write(path, value)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(vim.split(value, "\n"), path)
end
write(task .. "/plugin/.project", "<projectDescription/>")
write(task .. "/plugin/First.java", "class First {}")
write(task .. "/plugin/Second.java", "class Second {}")
write(task .. "/empty.target", "<target/>")
write(
	task .. "/style.xml",
	[[<profiles><profile name="Team">
<setting id="org.eclipse.jdt.core.formatter.tabulation.char" value="tab"/>
<setting id="org.eclipse.jdt.core.formatter.tabulation.size" value="4"/>
</profile></profiles>]]
)
write(
	task .. "/javaConfig.json",
	vim.json.encode({
		projects = { "plugin" },
		targetPlatform = "empty.target",
		formatter = { path = "style.xml", profile = "Team" },
	})
)
local java = vim.fn.resolve(vim.fn.exepath("java"))
write(task .. "/fake.jar", "fixture")
write(task .. "/bundles.json", vim.json.encode({ task .. "/fake.jar" }))
vim.env.XDG_CONFIG_HOME = task .. "/config"
write(
	task .. "/config/nvim-pde/tools.json",
	vim.json.encode({
		jdtls = vim.fn.exepath("true"),
		flock = vim.fn.exepath("true"),
		javaHome = vim.fs.dirname(vim.fs.dirname(java)),
		bundles = task .. "/bundles.json",
	})
)
local clients, nextid, reloads = {}, 0, 0
local function start(config, opts)
	nextid = nextid + 1
	local id = nextid
	local client = {
		id = id,
		name = "jdtls",
		config = config,
		settings = config.settings,
		handlers = vim.deepcopy(config.handlers),
		attached_buffers = {},
		initialized = true,
		server_capabilities = { executeCommandProvider = { commands = { "java.pde.reloadTargetPlatform" } } },
		rpc = {
			is_closing = function()
				return true
			end,
		},
	}
	clients[id] = client
	client.stop = function()
		clients[id] = nil
		config.on_exit(0, 0)
	end
	client.request = function(_, _, params, callback)
		if params.command == "java.pde.reloadTargetPlatform" then
			reloads = reloads + 1
			callback(nil)
		else
			local settings = {}
			for _, key in ipairs(params.arguments[2]) do
				settings[key] = ({
					["org.eclipse.jdt.core.formatter.tabulation.char"] = "tab",
					["org.eclipse.jdt.core.formatter.tabulation.size"] = "4",
					["org.eclipse.jdt.core.formatter.lineSplit"] = "140",
					["org.eclipse.jdt.ls.core.sourcePaths"] = { task .. "/plugin" },
				})[key]
			end
			callback(nil, settings)
		end
		return true
	end
	vim.schedule(function()
		config.on_init(client)
		if opts then
			vim.lsp.buf_attach_client(opts.bufnr, id)
		end
	end)
	return id
end
vim.lsp.start = start
vim.lsp.start_client = start
vim.lsp.get_client_by_id = function(id)
	return clients[id]
end
vim.lsp.get_clients = function()
	return vim.tbl_values(clients)
end
vim.lsp.buf_attach_client = function(buf, id)
	local client = assert(clients[id])
	if client.attached_buffers[buf] then
		return true
	end
	client.attached_buffers[buf] = true
	client.config.on_attach(client, buf)
	vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = id } })
	return true
end
vim.cmd.runtime("plugin/jdtls.lua")
local pde = require("config.pde")
pde.setup()
vim.cmd.edit(task .. "/plugin/First.java")
vim.bo.filetype = "java"
local first = vim.api.nvim_get_current_buf()
pde.start()
assert(vim.wait(500, function()
	return clients[1].attached_buffers[first]
end))
vim.cmd.edit(task .. "/plugin/Second.java")
vim.bo.filetype = "java"
vim.bo.expandtab, vim.bo.shiftwidth = true, 2
vim.api.nvim_buf_delete(first, { force = true })
clients[1].attached_buffers[first] = nil
clients[1].handlers["language/status"](nil, { type = "ServiceReady", message = "Ready" }, { client_id = 1 })
assert(not vim.bo.expandtab and vim.bo.shiftwidth == 4, "Wiping startup buffer must not lose formatter readiness")
-- The upstream configuration handler must retain explicit formatter settings,
-- even when an unrelated buffer uses a different indentation style.
vim.bo.expandtab, vim.bo.shiftwidth = true, 2
clients[1].handlers["workspace/configuration"](nil, { items = { { section = "java" } } }, { client_id = 1 })
assert(clients[1].settings.java.format.insertSpaces == false and clients[1].settings.java.format.tabSize == 4)
vim.wait(50)
local prompts = 0
vim.ui.select = function()
	prompts = prompts + 1
end
vim.cmd.JdtWipeDataAndRestart()
assert(
	prompts == 0 and clients[1] and nextid == 1,
	"Managed cache wipe must be blocked before upstream confirmation/deletion"
)
vim.cmd.JdtRestart()
assert(vim.wait(1000, function()
	return clients[2] and not clients[1]
end))
assert(vim.wait(500, function()
	return clients[2].attached_buffers[vim.api.nvim_get_current_buf()]
end))
pde.reload_target(task .. "/empty.target")
assert(reloads == 1, "Reload must use the replacement client")
pde.stop()
vim.wait(50)
assert(not next(clients), "PdeStop must stop the replacement client")
print("PASS: upstream lifecycle, wiped startup buffer, restart ownership, safe wipe refusal, formatter configuration")
vim.cmd("qa!")
