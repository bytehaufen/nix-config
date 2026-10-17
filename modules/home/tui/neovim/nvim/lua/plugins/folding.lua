return {
  { -- QoL features for folding
    "chrisgrieser/nvim-origami",
    dependencies = { "kevinhwang91/nvim-ufo" },
    event = "VeryLazy",
    opts = {
      foldKeymaps = {
        setup = true,
        closeOnlyOnFirstColumn = true,
      },
      autoFold = {
        enabled = true,
        kinds = { "imports" }, ---@type lsp.FoldingRangeKind[]
      },
    },
    -- Disable vim's auto-folding
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}
