return {
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "mfussenegger/nvim-dap" },
    lazy = false,
    config = function()
      require("config.pde").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- config.pde owns the native jdtls config/enable call; skip LazyVim's
      -- generic Java setup and Mason installation/automatic activation.
      servers = { jdtls = { enabled = false } },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
