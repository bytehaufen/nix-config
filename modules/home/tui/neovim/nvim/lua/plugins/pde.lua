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
      servers = { jdtls = { mason = false, enabled = false } },
      setup = {
        jdtls = function()
          return true
        end,
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(server)
        return not server:match("^jdtls@?")
      end, opts.ensure_installed or {})
      if opts.automatic_enable == nil or opts.automatic_enable == true then
        opts.automatic_enable = { exclude = { "jdtls" } }
      elseif type(opts.automatic_enable) == "table" then
        if opts.automatic_enable.exclude then
          table.insert(opts.automatic_enable.exclude, "jdtls")
        else
          opts.automatic_enable = vim.tbl_filter(function(server)
            return server ~= "jdtls"
          end, opts.automatic_enable)
        end
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
}
