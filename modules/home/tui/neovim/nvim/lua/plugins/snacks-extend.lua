return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.scroll = { enabled = false }

      opts.picker = {
        enabled = true,
        ui_select = true,
        layout = { preset = "ivy", preview = "right" },
        win = { preview = { enabled = true, wrap = true, width = 0.5 } },
      }

      opts.image = opts.image or {}
      opts.image.enabled = true
    end,
  },
}
