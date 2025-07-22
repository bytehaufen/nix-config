{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
      };

      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    home = {
      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };

      packages = with pkgs; [
        # General
        just # Make like command runner
        tree-sitter # Language parser

        # Nix
        alejandra # Nix Code Formatter
        cachix # Nix binary cache client
        deadnix # Find and remove unused code in .nix source files
        lorri # Nix project development environment
        nix-output-monitor # nom
        nil # Nix language server
        nixd # Nix language server
        statix # Lints and suggestions for the nix programming language

        taplo # TOML language server / formatter / validator
        nodePackages.yaml-language-server
        actionlint # GitHub Actions linter

        # Dockerfile
        hadolint # Dockerfile linter
        nodePackages.dockerfile-language-server-nodejs

        # Markdown
        glow # markdown previewer
        marksman # language server for markdown
        pandoc # document converter

        # Sql
        sqlfluff

        # C/C++
        checkmake
        clang-tools
        cmake
        cmake-language-server
        gcc
        gdb
        gnumake
        lldb
        vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb - debugger

        # Python
        pyright # Python language server
        (python312.withPackages (
          ps:
            with ps; [
              cairosvg
              grip
              ipykernel
              ipython
              jupyter
              jupyter-client
              nbformat
              pandas
              plotly
              pnglatex
              pylatexenc
              pyperclip
              pyquery
              pynvim
              pyyaml
              requests
              tabulate

              pip
            ]
        ))

        # Rust
        cargo # Rust package manager
        clippy # Rust linter
        rust-analyzer
        rustc
        rustfmt

        # Java
        gradle
        maven
        jdk
        jdt-language-server

        # Lua
        lua5_1
        lua-language-server
        lua51Packages.luarocks
        luajitPackages.magick # Lua bindings for ImageMagick
        luajitPackages.lpeg # Lua parsing expression grammars
        stylua

        # Bash
        nodePackages.bash-language-server
        shellcheck
        shfmt

        # Web dev
        emmet-ls
        nodePackages.nodejs
        nodePackages.typescript
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages."@tailwindcss/language-server"

        # English prose linter
        proselint

        # Optional
        ast-grep
        nodePackages.prettier # Common code formatter
        (ripgrep.override {withPCRE2 = true;}) # Recursively searches directories for a regex pattern
        tectonic
      ];
    };
  };
}
