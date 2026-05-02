return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bacon_ls = {
          enabled = true,
          settings = {
            bacon_ls = {
              backend = "cargo",
              cargo = {
                command = "clippy",
                extraArgs = {
                  "--workspace",
                  "--all-targets",
                  "--all-features",
                  "--profile",
                  "test",
                },
              },
            },
          },
        },
      },
    },
  },
}
