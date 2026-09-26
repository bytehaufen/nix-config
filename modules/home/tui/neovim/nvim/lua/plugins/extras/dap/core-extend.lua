return {
  {
    "rcarriga/nvim-dap-ui",
    enabled = false,
  },

  {
    "mfussenegger/nvim-dap",
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    dependencies = {
      "igorlfs/nvim-dap-view",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

    keys = {
      { "<F9>", "<leader>db", desc = "Toggle Breakpoint", remap = true },
      { "<F8>", "<leader>dc", desc = "Continue", remap = true },
      { "<F11>", "<leader>dc", desc = "Continue", remap = true },
      { "<F5>", "<leader>di", desc = "Step Into", remap = true },
      { "<F7>", "<leader>do", desc = "Step Out", remap = true },
      { "<F6>", "<leader>dO", desc = "Step Over", remap = true },

      {
        "<leader>du",
        function()
          require("dap-view").toggle()
        end,
        desc = "Dap View",
      },
      {
        "<leader>de",
        function()
          require("dap-view").hover()
        end,
        mode = { "n", "x" },
        desc = "Eval",
      },
    },

    opts = function(_, opts)
      local dap = require("dap")

      require("dap-view").setup({
        auto_toggle = true,
        follow_tab = true,

        winbar = {
          sections = {
            "scopes",
            "watches",
            "breakpoints",
            "threads",
            "repl",
          },
          default_section = "scopes",
        },

        windows = {
          position = "right",
          size = 0.30,

          terminal = {
            position = "below",
            size = 0.30,
          },
        },

        switchbuf = "useopen,usetab,uselast",
      })

      dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-repl",
        callback = function()
          require("dap.ext.autocompl").attach()
        end,
      })

      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
        callback = function()
          local ft = vim.bo.filetype

          if
            vim.tbl_contains({
              "dap-view",
              "dap-view-term",
              "dap-view-hover",
              "dap-view-help",
              "dap-repl",
            }, ft)
          then
            vim.wo.spell = false
          end
        end,
        desc = "Disable spellcheck in DAP views",
      })

      return opts
    end,
  },
}
