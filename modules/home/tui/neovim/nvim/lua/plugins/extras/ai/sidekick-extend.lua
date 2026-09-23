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
    opts = {
      nes = {
        enabled = false,
      },
    },
  },
}
