{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  gtkTheme = pkgs.catppuccin-gtk.override {
    accents = ["blue"];
    variant = "mocha";
  };
in {
  imports = [inputs.catppuccin.homeModules.catppuccin];

  config = lib.mkIf config.opts.home.tui.enable {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "blue";
    };

    # Default installed fonts
    home = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        noto-fonts-color-emoji

        dejavu_fonts
        julia-mono
        liberation_ttf
        nerd-fonts.symbols-only
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        noto-fonts
        noto-fonts-cjk-sans

        source-sans
        source-serif
        source-han-sans
        source-han-serif
      ];

      pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
      };
    };

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [
            "DejaVu Serif"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "DejaVu Sans"
            "Noto Color Emoji"
          ];
          monospace = [
            "FiraCode Nerd Font"
            "Noto Color Emoji"
          ];

          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "catppuccin-mocha-blue-standard";
        package = gtkTheme;
      };
      gtk4.theme = config.gtk.theme;
      colorScheme = "dark";

      font.name = "DejaVu Sans";
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "kvantum";
    };
  };
}
