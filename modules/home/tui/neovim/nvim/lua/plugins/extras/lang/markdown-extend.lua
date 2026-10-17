return {
  -- Replace LazyVims Markdown renderer with Markview
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    config = function(_, opts)
      local doc = require("snacks.image.doc")
      local inline = require("snacks.image.inline")
      local renderers = setmetatable({}, { __mode = "v" })

      local function paused(buf)
        return not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].markdown_images_disabled == true
      end

      -- Block new images, including pending asynchronous results.
      local find = doc.find
      doc.find = function(buf, callback, find_opts)
        if paused(buf) then
          return callback({})
        end
        return find(buf, function(images)
          if vim.api.nvim_buf_is_valid(buf) then
            callback(paused(buf) and {} or images)
          end
        end, find_opts)
      end

      -- Clear images and pause updates while Markview is disabled.
      local update = inline.update
      inline.update = function(self)
        renderers[self.buf] = self
        if paused(self.buf) then
          for _, img in pairs(self.imgs) do
            img:close()
          end
          self.imgs, self.idx = {}, {}
          return
        end
        return update(self)
      end

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("MarkdownImages", { clear = true }),
        pattern = { "MarkviewEnable", "MarkviewDisable" },
        callback = function(event)
          local buf = event.data.buffer
          vim.b[buf].markdown_images_disabled = event.match == "MarkviewDisable"
          if renderers[buf] then
            renderers[buf]:update()
          end
        end,
      })

      require("markview").setup(opts)
    end,

    keys = {
      {
        "<leader>um",
        "<cmd>Markview toggle<cr>",
        ft = "markdown",
        desc = "Toggle Markview",
      },
    },
    opts = { latex = { enable = false } },
  },

  {
    "iamcco/markdown-preview.nvim",

    -- NOTE: Init is the dirty way, but not all settings are taken when using opts
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_combine_preview = 1
      vim.g.mkdp_combine_preview_auto_refresh = 1
      vim.g.mkdp_auto_start = 0
    end,
  },
}
