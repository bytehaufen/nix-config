{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  tokyo-night-gtk = pkgs.tokyo-night-gtk.override {
    colorVariants = [
      "dark"
    ];
    sizeVariants = [
      "standard"
    ];
    themeVariants = [
      "default"
    ];
    tweakVariants = [
      "moon"
      "storm"
    ];
    iconVariants = [
      "Dark"
    ];
  };
in {
  imports = [
    # Base16 color schemes
    inputs.nix-colors.homeManagerModules.default
  ];

  config = lib.mkIf config.opts.home.tui.enable {
    # Default installed fonts
    home = {
      packages = with pkgs; [
        material-design-icons
        font-awesome
        noto-fonts-emoji

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

      font.name = "DejaVu Sans";

      theme = {
        name = "Tokyonight-Dark-Storm";
        package = tokyo-night-gtk;
      };

      iconTheme = {
        name = "Tokyonight-Dark";
        package = tokyo-night-gtk;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
    ## Available color schemes: [base16-schemes](https://github.com/tinted-theming/base16-schemes) -> file name without `.yml`
    # Access colors by e.g.: `config.colorScheme.palette.base05`
    colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
    # Color reference for Tokyo Night Storm:
    # base00 = "#24283b" Default Background
    # base01 = "#16161e" Lighter Background (Used for status bars, line number and folding marks)
    # base02 = "#343a52" Selection Background
    # base03 = "#444b6a" Comments, Invisibles, Line Highlighting
    # base04 = "#787c99" Dark Foreground (Used for status bars)
    # base05 = "#a9b1d6" Default Foreground, Caret, Delimiters, Operators
    # base06 = "#cbccd1" Light Foreground (Not often used)
    # base07 = "#d5d6db" Light Background (Not often used)
    # base08 = "#c0caf5" Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    # base09 = "#a9b1d6" Integers, Boolean, Constants, XML Attributes, Markup Link Url
    # base0A = "#0db9d7" Classes, Markup Bold, Search Text Background
    # base0B = "#9ece6a" Strings, Inherited Class, Markup Code, Diff Inserted
    # base0C = "#b4f9f8" Support, Regular Expressions, Escape Characters, Markup Quotes
    # base0D = "#2ac3de" Functions, Methods, Attribute IDs, Headings
    # base0E = "#bb9af7" Keywords, Storage, Selector, Markup Italic, Diff Changed
    # base0F = "#f7768e" Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
  };
}
