return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = {
        enabled = true,
        ui_select = true,
        layout = { preset = "ivy", preview = "right" },
        win = { preview = { enabled = true, wrap = true, width = 0.5 } },
      }
    end,
  },
}
