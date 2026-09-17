-- Let mini.diff handle visualization
return {
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,

    -- Let mini.diff handle visualization
    opts = function(_, opts)
      local original_on_attach = opts.on_attach

      opts.on_attach = function(bufnr)
        if original_on_attach then
          original_on_attach(bufnr)
        end

        local gs = require("gitsigns")

        vim.keymap.set("n", "<leader>ghs", function()
          gs.stage_hunk(nil, nil, function(err)
            if err then
              vim.notify(err, vim.log.levels.ERROR)
              return
            end

            gs.nav_hunk("next")
          end)
        end, {
          buffer = bufnr,
          desc = "Stage Hunk and Next",
        })
      end
    end,
  },
}
