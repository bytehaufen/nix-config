-- Disable some extension providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

vim.g.autoformat = false
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

vim.g.lazyvim_rust_diagnostics = "bacon-ls"

-- Remove the default `~` char for end of buffer
vim.opt.fillchars = "eob: "

-- Root markers, first lsp, then file/directory patterns
vim.g.root_spec = {
  "lsp",
  {
    ".git",
    ".lazy.lua",
    ".project", -- Eclipse project file
    ".svn",
    "Makefile",
    "make.sh",
  },
}

-- Add extra filetypes to exclude lsps for that
vim.filetype.add({
  filename = {
    [".env"] = "env",
  },
  pattern = {
    ["/dev/shm/pass%.%w+/.*"] = "pass",
  },
})

-- Spell check
vim.opt.spelllang = { "en", "de_20" }
vim.opt.spell = true

local options = {
  autoindent = true,
  autowrite = true,
  backspace = "indent,eol,start",
  backup = false, -- creates no backup file
  breakindent = true,
  clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 1, -- more space in the neovim command line for displaying messages
  colorcolumn = "+1", -- vertical bar at 100 characters
  completeopt = "menu,menuone,noselect", -- mostly just for cmp
  conceallevel = 0, -- so that `` is visible in markdown files
  confirm = true, -- Confirm to save changes before exiting modified buffer
  cursorline = true, -- highlight the current line
  expandtab = true, -- convert tabs to spaces
  fileencoding = "utf-8", -- the encoding written to a file
  formatoptions = "jcroqlnt", -- tcqj
  grepformat = "%f:%l:%c:%m",
  grepprg = "rg --vimgrep",
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  inccommand = "split", -- preview incremental substitute
  laststatus = 3,
  list = true,
  listchars = { trail = "", tab = "", nbsp = "_", extends = ">", precedes = "<" }, -- highlight
  mouse = "a", -- allow the mouse to be used in neovim
  number = true, -- set numbered lines
  numberwidth = 2, -- set number column width to 2 {default 4}
  -- pumblend = 10, -- Popup blen
  -- pumheight = 10, -- pop up menu height
  relativenumber = true, -- set relative numbered lines
  scrolloff = 10, -- is one of my fav
  sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
  shell = "zsh",
  shiftround = true, -- Round indent
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  showcmd = false,
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 0, -- always show tabs
  si = true,
  sidescrolloff = 8,
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  smarttab = true,
  splitbelow = true, -- force all horizontal splits to go below current window
  splitkeep = "screen",
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  tabstop = 2, -- insert 2 spaces for a tab
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
  textwidth = 100, -- text width for linebreak width `gq`
  undodir = os.getenv("HOME") .. "/.vim/undodir",
  undofile = true, -- enable persistent undo
  undolevels = 10000,
  updatetime = 50, -- faster completion (4000ms default)
  wildmenu = true, -- wildmenu
  wildmode = "longest:full,full", -- Command-line completion mode
  winminwidth = 5, -- Minimum window width
  wrap = false, -- display lines as one long line
  writebackup = false, -- do not edit backups
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
