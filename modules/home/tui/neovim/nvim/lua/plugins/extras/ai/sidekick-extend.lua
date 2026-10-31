return {
  {
    "folke/sidekick.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("sidekick_follow_output", {
        clear = true,
      })

      vim.api.nvim_create_autocmd({ "TermLeave", "WinLeave" }, {
        group = group,
        callback = function(ev)
          if vim.bo[ev.buf].filetype ~= "sidekick_terminal" then
            return
          end

          if not vim.b[ev.buf].sidekick_cli then
            return
          end

          local last = vim.api.nvim_buf_line_count(ev.buf)

          for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
            pcall(vim.api.nvim_win_set_cursor, win, { last, 0 })
          end
        end,
      })
    end,

    -- Show tmux window name in sidekick picker. Workaround for open PR https://github.com/folke/sidekick.nvim/pull/319
    config = function(_, opts)
      require("sidekick").setup(opts)

      local select = require("sidekick.cli.ui.select")
      local original_select = select.select
      local original_format = select.format
      local strwidth = vim.api.nvim_strwidth

      local windows = {}
      local repo_col = 40

      local function formatted(state, picker)
        local parts = original_format(state, picker)
        if not state.session then
          return parts
        end

        for i, part in ipairs(parts) do
          if part[2] == "Special" then
            local pane = state.external and state.session.tmux_pane_id

            if pane then
              if windows[pane] == nil then
                local lines = vim.fn.systemlist({
                  "tmux",
                  "display-message",
                  "-p",
                  "-t",
                  pane,
                  "-F",
                  "#{window_name}",
                })
                windows[pane] = vim.v.shell_error == 0 and vim.trim(lines[1] or "") or ""
              end

              local window = windows[pane]
              if window ~= "" then
                part[1] = part[1]:sub(1, -2) .. ":" .. window .. "]"
              end
            end

            local width = 0
            for j = (picker and 3 or 1), i do
              width = width + strwidth(parts[j][1])
            end

            return parts, i + 1, width
          end
        end

        return parts
      end

      -- Determine the shared repository column when opening the picker
      select.select = function(select_opts)
        windows = {}
        repo_col = 40

        for _, state in ipairs(require("sidekick.cli.state").get(select_opts.filter)) do
          local _, padding_idx, width = formatted(state)
          if padding_idx then
            repo_col = math.max(repo_col, width + 2)
          end
        end

        return original_select(select_opts)
      end

      select.format = function(state, picker)
        local parts, padding_idx, width = formatted(state, picker)

        if padding_idx then
          parts[padding_idx][1] = string.rep(" ", repo_col - width)
        end

        return parts
      end
    end,
    opts = {
      nes = {
        enabled = false,
      },
      cli = {
        tools = {
          pi = {
            cmd = { "omp" },
            is_proc = "\\<omp\\>",
            url = "https://github.com/can1357/oh-my-pi",
          },
        },
      },
    },
  },
}
