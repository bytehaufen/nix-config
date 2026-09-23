{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.opts.home.gui.enable {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;
      keybindings = {
        "ctrl+shift+v" = "paste_from_clipboard";
        "ctrl+v" = "paste_from_clipboard";
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+shift+plus" = "change_font_size all +1.0";
        "ctrl+shift+minus" = "change_font_size all -1.0";
        "ctrl+shift+0" = "change_font_size all 0";
        "ctrl+shift+u" = "kitten unicode_input";
      };

      font = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
        size = 10;
      };

      themeFile = "tokyo_night_night";

      settings = {
        auto_reload_config = -42.0; # Negative value == disable
        scrollback_lines = 10000;
        confirm_os_window_close = 0;
        window_padding_width = 5;
        copy_on_select = true;
        enable_audio_bell = false;
        allow_remote_control = true;
        listen_on = "unix:@mykitty";
        close_on_child_death = true;

        background_opacity = 1.0;
        # Kitty detects and uses the semibold version, so we need to override
        bold_font = "postscript_name=JetBrainsMono-ExtraBold";
        bold_italic_font = "postscript_name=JetBrainsMono-ExtraBoldItalic";
        symbol_map = ''
          U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ea60-U+ec1e,U+ed00-U+efce,U+f000-U+f2ff,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono
        '';
      };
    };

    home.packages = [
      # used by `gio open` and xdg-gtk
      (pkgs.writeShellScriptBin "xdg-terminal-exec" ''
        kitty "$@"
      '')
      pkgs.xdg-utils
    ];
  };
}
