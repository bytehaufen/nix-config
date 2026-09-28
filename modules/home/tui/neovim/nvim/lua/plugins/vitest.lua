return {
  "nvim-neotest/neotest",
  dependencies = { "nvim-treesitter/nvim-treesitter", "marilari88/neotest-vitest" },
  opts = {
    adapters = {
      ["neotest-vitest"] = {
        vitestCommand = function(path)
          local root = vim.fs.root(path, "package.json")
          if root then
            return root .. "/node_modules/.bin/vitest --environment jsdom"
          end
          return "vitest --environment jsdom"
        end,
      },
    },
  },
}
