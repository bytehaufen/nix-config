{
  config,
  lib,
  pkgs,
  ...
}: let
  configPath = "${config.home.homeDirectory}/nix-config/modules/home/gui/zed/config";
in {
  config = lib.mkIf config.opts.home.gui.enable {
    home.packages = with pkgs; [
      bubblewrap
    ];

    programs.zed-editor = {
      enable = true;

      extraPackages = with pkgs; [
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
        vscode-langservers-extracted
      ];
    };

    xdg.configFile."zed".source =
      config.lib.file.mkOutOfStoreSymlink "${configPath}";

    programs.zsh.shellAliases.zed = "zeditor";
  };
}
