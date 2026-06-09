-- btop
if vim.fn.executable("btop") == 1 then
  vim.keymap.set("n", "<leader>xb", function()
    Snacks.terminal.open("btop")
  end, { desc = "btop" })
end

-- Exit insert mode with jk
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true, desc = "<Esc>" })

-- Activate Tmux seamless navigating
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")

vim.keymap.set("n", "vv", "<C-v>", { noremap = false, silent = true, desc = "Enter visual block mode" })

vim.keymap.set("n", "U", "<C-r>, ", { noremap = true, silent = true, desc = "Redo" })

vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true, desc = "Delete without yanking" })
vim.keymap.set("n", "X", '"_X', { noremap = true, silent = true, desc = "Delete without yanking" })

-- Keys for German umlauts
vim.keymap.set("i", "<A-u>", "ü", { desc = "Insert German ü" })
vim.keymap.set("i", "<A-a>", "ä", { desc = "Insert German ä" })
vim.keymap.set("i", "<A-o>", "ö", { desc = "Insert German ö" })
vim.keymap.set("i", "<A-s>", "ß", { desc = "Insert German ß" })

-- Uppercase umlauts
vim.keymap.set("i", "<S-A-u>", "Ü", { desc = "Insert German Ü" })
vim.keymap.set("i", "<S-A-a>", "Ä", { desc = "Insert German Ä" })
vim.keymap.set("i", "<S-A-o>", "Ö", { desc = "Insert German Ö" })

vim.keymap.set("n", "gl", function()
  vim.cmd("normal! m'")
  vim.cmd("normal! yyP")
  vim.cmd("normal gcc")
  vim.cmd("normal! ``")
end, { desc = "Yank, paste, and comment selection" })

vim.keymap.set("v", "gl", function()
  vim.cmd("normal! y")
  vim.cmd("normal! `[P")
  vim.cmd("normal! `[V`]")
  vim.cmd("normal gc")
end, { desc = "Yank, paste, and comment pasted selection" })

vim.keymap.set("x", "p", '"_dP', {
  noremap = true,
  silent = true,
  desc = "Paste over selection without yanking replaced text",
})
