local function compare(prompt, default, suffix)
  return function()
    vim.ui.input({ prompt = prompt, default = default }, function(revision)
      if revision and revision ~= "" then
        vim.cmd.DiffviewOpen({ revision .. (suffix or "") })
      end
    end)
  end
end

return {
  -- Git diff view
  {
    "sindrets/diffview.nvim",
    cmd = "DiffviewOpen",
    keys = {
      { "<leader>gdd", mode = { "n" }, "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gdr", "<cmd>DiffviewOpen<cr>", desc = "Diffview working tree" },
      { "<leader>gda", "<cmd>DiffviewOpen HEAD<cr>", desc = "Diffview all local changes" },
      { "<leader>gds", "<cmd>DiffviewOpen --cached<cr>", desc = "Diffview staged changes" },
      {
        "<leader>gdb",
        compare("Base branch: ", "main", "...HEAD"),
        desc = "Diffview branch changes",
      },
      {
        "<leader>gdt",
        compare("Compare branch tip: ", "main", "..HEAD"),
        desc = "Diffview branch tips",
      },
      {
        "<leader>gdw",
        compare("Working tree against: ", "main"),
        desc = "Diffview working tree against ref",
      },
      {
        "<leader>gdc",
        compare("Commit or range (e.g. HEAD^!): ", "HEAD~1..HEAD"),
        desc = "Diffview commits",
      },
      { "<leader>gdh", mode = { "n" }, "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History" },
      { "<leader>gdq", mode = { "n" }, "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gde", mode = { "n" }, "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview Toggle Files" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      spec = {
        mode = { "n", "v" },
        { "<leader>gd", group = "Diffview" },
      },
    },
  },
}
