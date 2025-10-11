return {
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "fang2hou/blink-copilot" },
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        sources = {
          default = { "copilot" },
          providers = {
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              score_offset = 0,
              min_keyword_length = 2,
              async = true,
            },
          },
        },
      })
    end,
  },
}
