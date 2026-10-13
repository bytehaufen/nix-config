return {
  {
    "esmuellert/codediff.nvim",
    version = "*",
    cmd = "CodeDiff",
    build = "bash build.sh",
    opts = {
      diff = {
        layout = "side-by-side",
        disable_inlay_hints = true,
      },
      explorer = {
        width = 32,
        view_mode = "tree",
        focus_on_select = true,
      },
      keymaps = {
        view = {
          toggle_explorer = "<leader>grf",
          focus_explorer = "<leader>grF",
        },
        explorer = {
          stage_all = false,
          unstage_all = false,
          restore = false,
        },
      },
    },
  },

  {
    "georgeguimaraes/review.nvim",
    version = "*",
    event = "VeryLazy",
    cmd = "Review",
    dependencies = {
      "esmuellert/codediff.nvim",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>grr", "<cmd>Review<cr>", desc = "Review working tree" },
      { "<leader>grb", "<cmd>Review branch<cr>", desc = "Review branch" },
      { "<leader>grc", "<cmd>Review commits<cr>", desc = "Review commits" },
      { "<leader>grn", ":Review note<cr>", mode = { "n", "x" }, desc = "Review: add note" },
      { "<leader>gre", "<cmd>Review edit<cr>", desc = "Review: edit comment" },
      { "<leader>grd", "<cmd>Review delete<cr>", desc = "Review: delete comment" },
      { "<leader>grl", "<cmd>Review list<cr>", desc = "Review: list comments" },
      { "<leader>grp", "<cmd>Review preview<cr>", desc = "Review: preview feedback" },
      { "<leader>grs", "<cmd>Review sidekick<cr>", desc = "Review: send to Sidekick" },
    },
    opts = {
      codediff = {
        readonly = true,
      },
      keymaps = {
        clear_comments = false,
      },
      export = {
        clipboard = true,
        clear_on_close = true,
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts_extend = { "spec" },
    opts = {
      spec = {
        { "<leader>gr", group = "Review", mode = { "n", "v" } },
      },
    },
  },

  {
    "pwntester/octo.nvim",
    optional = true,
    keys = {
      -- Reserve this prefix for the review mappings.
      { "<leader>gr", false },
    },
  },
}
