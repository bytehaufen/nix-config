-- Run from the repository root; no plugins or language server are started.
vim.env.XDG_STATE_HOME = vim.fn.tempname()
vim.g.mapleader = " "
vim.o.timeoutlen = 20
for _, key in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
	vim.keymap.set("n", key, "<Nop>") -- Defaults removed by config/keymaps.lua.
end
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>")
local next_tab = vim.fn.maparg("<leader><tab>]", "n")
local calls = {}
vim.lsp.buf.typehierarchy = function(kind)
	calls[#calls + 1] = kind
end
dofile("modules/home/tui/neovim/nvim/lua/config/keymaps.lua")
assert(vim.fn.maparg("gt", "n") == "<Nop>", "Standalone gt must be disabled globally")
assert(vim.fn.maparg("<leader><tab>]", "n") == next_tab, "Leader tab navigation must remain unchanged")
vim.cmd.tabnew()
local tab = vim.api.nvim_get_current_tabpage()
vim.api.nvim_feedkeys("gt", "xt", false)
assert(vim.api.nvim_get_current_tabpage() == tab, "gt must not change tabs")
vim.api.nvim_feedkeys("gthgtl", "xt", false)
assert(vim.deep_equal(calls, { "supertypes", "subtypes" }), "Both hierarchy mappings must work past the gt prefix")
assert(vim.api.nvim_get_current_tabpage() == tab, "Hierarchy mappings must not change tabs")
print("PASS: global gt disabled, gth/gtl dispatch correctly, leader tab mapping preserved")
vim.cmd.quitall()
