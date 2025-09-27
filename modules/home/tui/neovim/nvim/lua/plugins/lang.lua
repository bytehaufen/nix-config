return {
  -- Additional LSP's to be installed by mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "bashls",
          "dockerls",
          "gradle_ls",
          "html",
          "arduino_language_server",
          "docker_compose_language_service",
        })
      end
      opts.automatic_installation = true
      return opts
    end,
  },
}
