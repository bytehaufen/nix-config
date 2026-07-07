{
  lib,
  config,
  pkgs,
  ...
}: {
  config =
    lib.mkIf config.opts.home.windowManager.niri.enable
    {
      programs.swaylock = let
        inherit (config.colorScheme) palette;

        primary = palette.base0A;
        secondary = palette.base0C;
        onSecondary = palette.base03;
        surface = palette.base00;
        surfaceBright = palette.base06;
        error = palette.base0F;
        onError = palette.base01;
        onTertiary = palette.base01;
      in {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          clock = true;
          image = "${config.opts.home.theme.wallpaper}";
          effect-blur = "20x3";
          fade-in = 0.1;

          font-size = 20;

          line-uses-inside = true;
          disable-caps-lock-text = true;
          ignore-empty-password = true;
          indicator-caps-lock = true;
          indicator-radius = 100;
          indicator-idle-visible = true;

          ring-color = surfaceBright;
          inside-wrong-color = onError;
          ring-wrong-color = error;
          key-hl-color = primary;
          bs-hl-color = onTertiary;
          ring-ver-color = secondary;
          inside-ver-color = onSecondary;
          inside-color = surface;
          text-color = surfaceBright;
          text-clear-color = surfaceBright;
          text-ver-color = onSecondary;
          text-wrong-color = error;
          text-caps-lock-color = surfaceBright;
          inside-clear-color = surface;
          ring-clear-color = primary;
          inside-caps-lock-color = onTertiary;
          ring-caps-lock-color = surface;
          separator-color = surface;
        };
      };
    };
}
