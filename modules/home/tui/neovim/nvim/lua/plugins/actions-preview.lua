return {
  -- Disable LazyVim's existing
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          { "<leader>ca", false },
        },
      },
    },
  },
  {
    "aznhe21/actions-preview.nvim",
    keys = {
      {
        "<leader>ca",
        function()
          require("actions-preview").code_actions()
        end,
        mode = { "n", "v" },
        desc = "Code action preview",
      },
    },
    opts = {
      highlight_command = {
        function()
          return require("actions-preview.highlight").delta()
        end,
      },
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
      },
    },
  },
}
