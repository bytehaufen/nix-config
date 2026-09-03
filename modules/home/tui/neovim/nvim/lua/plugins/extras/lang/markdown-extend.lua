return {
  -- Replace LazyVims Markdown renderer with Markview
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    keys = {
      {
        "<leader>um",
        "<cmd>Markview toggle<cr>",
        ft = "markdown",
        desc = "Toggle Markview",
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",

    -- NOTE: Init is the dirty way, but not all settings are taken when using opts
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
      vim.g.mkdp_auto_start = 0
    end,
  },
}
