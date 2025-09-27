return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      show_dir_path_in_prompt = true,
    },
  },
  keys = {
    { "<leader>i", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
