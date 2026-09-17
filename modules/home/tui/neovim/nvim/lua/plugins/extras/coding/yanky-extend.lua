return {
  {
    "gbprod/yanky.nvim",
    keys = {
      -- Remove Yanky's combined n+x mapping
      { "p", false, mode = { "n", "x" } },

      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = "n",
        desc = "Put Text After Cursor",
      },

      {
        "p",
        '"_dP',
        mode = "x",
        desc = "Paste over selection without yanking replaced text",
      },
    },
  },
}
