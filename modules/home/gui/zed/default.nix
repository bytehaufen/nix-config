{
  config,
  lib,
  pkgs,
  ...
}: let
  configPath = "${config.home.homeDirectory}/nix-config/modules/home/gui/zed/config";
in {
  config = lib.mkIf config.opts.home.gui.enable {
    # home.packages = lib.optionals config.opts.home.programs.openai-codex.enable [pkgs.codex-acp];

    programs.zed-editor = {
      enable = true;
      # Extensions may download language servers and debug adapters.
      # The FHS package allows their ordinary Linux binaries to run on NixOS.
      package = pkgs.zed-editor.fhs;

      extraPackages = with pkgs; [
        nodejs
        git
        ripgrep
        direnv
        alejandra
        nixd
        clang-tools
        cmake
        neocmakelsp
        go
        gopls
        delve
        basedpyright
        ruff
        rust-analyzer
        cargo
        rustc
        rustfmt
        clippy
        lua-language-server
        stylua
        bash-language-server
        shellcheck
        shfmt
        marksman
        markdownlint-cli2
        taplo
        yaml-language-server
        arduino-cli
        arduino-language-server
        just
        just-lsp
        jdk25
        stable.gradle
      ];

      # Only the shared palette is generated. Editor configuration stays JSON.
      themes.nix-colors = import ./theme.nix {
        inherit lib;
        palette = config.colorScheme.palette;
      };
    };

    # Link files individually so the generated themes directory can coexist.
    # Like Neovim, editing these files in Zed edits the checkout immediately.
    xdg.configFile =
      lib.genAttrs [
        "zed/settings.json"
        "zed/keymap.json"
        "zed/tasks.json"
        "zed/debug.json"
      ] (name: {
        source = config.lib.file.mkOutOfStoreSymlink "${configPath}/${baseNameOf name}";
      });

    programs.zsh.shellAliases.zed = "zeditor";
  };
}
