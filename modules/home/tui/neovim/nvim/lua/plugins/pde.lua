return {
  {
    "mfussenegger/nvim-jdtls",
    commit = "6e9d953f0b82bccdb834cfde0e893f3119c22592",
    lazy = false,
    config = function()
      require("config.pde").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- LazyVim also excludes disabled servers from Mason's automatic enable.
      servers = { jdtls = { enabled = false } },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
