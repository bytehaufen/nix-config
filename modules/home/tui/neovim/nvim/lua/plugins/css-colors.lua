return {
  {
    "uga-rosa/ccc.nvim",
    cmd = "CccPick",
    keys = {
      { "<leader>cP", "<Cmd>CccPick<CR>", desc = "Pick color" },
    },
    opts = {
      highlighter = {
        auto_enable = false,
      },
      point_char = "|",
      empty_point_bg = false,
      point_color_on_light = "#333333",
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "css", "scss", "sass", "html", "vue", "svelte", "javascriptreact", "typescriptreact", "lua", "nix" },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = true, -- Enable tailwind colors
        -- parsers can contain values used in |user_default_options|
        sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
        always_update = false,
      },
    },
  },
}
