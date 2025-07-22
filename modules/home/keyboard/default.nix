{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.windowManager.hyprland.enable {
    # My personal keyboard settings
    # Contain an English and a German layout
    # With <ESC> as <CAPS> and ` as <ESC> and ~ as <SHIFT>+<ESC>
    # For my 65% keyboard
    xdg.configFile = {
      "xkb/symbols/de-65".source = ./de-65;
      "xkb/symbols/en-65".source = ./en-65;
    };
  };
}
