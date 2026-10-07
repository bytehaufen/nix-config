-- Run from the repository root with installed LazyVim/lazy.nvim; never starts Java.
local config = vim.fn.getcwd() .. "/modules/home/tui/neovim/nvim"
local task = assert(vim.uv.fs_mkdtemp("/tmp/nvim-root.XXXXXX"))
vim.env.XDG_STATE_HOME = task .. "/state"
for _, plugin in ipairs({ "lazy.nvim", "LazyVim" }) do
	vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/" .. plugin)
end
_G.LazyVim = require("lazyvim.util")
dofile(config .. "/lua/config/options.lua")
local root = LazyVim.root
root.setup()
local function write(path, text)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile({ text or "" }, path)
end
local function check(path, expected)
	vim.cmd.edit(vim.fn.fnameescape(path))
	assert(root() == expected, ("Expected %s, got %s"):format(expected, root()))
end
-- Real Neovim client lifecycle with an in-process server: no Java or subprocess.
local function attach(path)
	local attached = false
	vim.api.nvim_create_autocmd("LspAttach", {
		buffer = 0,
		once = true,
		callback = function()
			attached = true
		end,
	})
	local id = assert(vim.lsp.start({
		name = "root-fixture",
		root_dir = path,
		cmd = function(dispatchers)
			local closed = false
			local function finish()
				closed = true
				dispatchers.on_exit(0, 0)
			end
			return {
				request = function(method, _, callback)
					vim.schedule(function()
						callback(nil, method == "initialize" and { capabilities = {} } or nil)
					end)
					return true, 1
				end,
				notify = function(method)
					if method == "exit" then
						finish()
					end
					return true
				end,
				is_closing = function()
					return closed
				end,
				terminate = finish,
			}
		end,
	}))
	assert(
		vim.wait(2000, function()
			return attached
		end),
		"LspAttach must invalidate the cached root"
	)
	return assert(vim.lsp.get_client_by_id(id))
end
local ok, failure = xpcall(function()
	local repo = task .. "/checkout"
	local plugin = repo .. "/plugin"
	local source = plugin .. "/src/Example.java"
	vim.fn.mkdir(repo .. "/.git", "p")
	write(plugin .. "/.project")
	write(plugin .. "/Makefile")
	write(source, "class Example {}")
	check(source, repo)
	local client = attach(plugin)
	assert(root() == repo, "A nested LSP must not narrow repository navigation")
	assert(client.root_dir == plugin, "Editor roots must not change LSP project scope")

	-- A .git file (worktrees/submodules) is also a boundary, not the outer repo.
	local nested = repo .. "/nested"
	write(nested .. "/.git", "gitdir: /unused/metadata")
	write(nested .. "/plugin/.project")
	write(nested .. "/plugin/Example.java", "class Example {}")
	check(nested .. "/plugin/Example.java", nested)

	local standalone = task .. "/standalone"
	write(standalone .. "/plugin/.project")
	write(standalone .. "/plugin/Example.java", "class Example {}")
	check(standalone .. "/plugin/Example.java", standalone .. "/plugin")
	attach(standalone)
	assert(root() == standalone, "Outside Git, LSP roots must retain priority over markers")

	write(task .. "/plain/notes.txt", "notes")
	check(task .. "/plain/notes.txt", vim.uv.cwd())
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do
	client:stop(true)
end
vim.wait(2000, function()
	return #vim.lsp.get_clients() == 0
end)
vim.fn.delete(task, "rf")
if not ok then
	error(failure)
end
print("PASS: Git root beats nested markers/LSP; .git files, non-Git LSP/project and cwd fallbacks")
vim.cmd("qa!")
