return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = function(_, opts)
      opts.flavour = "mocha"
      opts.background = vim.tbl_deep_extend("force", opts.background or {}, {
        light = "mocha",
        dark = "mocha",
      })
      opts.transparent_background = false
      opts.term_colors = true
      opts.auto_integrations = true

      return opts
    end,
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },
}
