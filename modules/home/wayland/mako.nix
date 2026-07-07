{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.windowManager.niri.enable {
    services.mako = let
      colors = config.colorScheme.palette;
    in {
      enable = true;

      settings = {
        icon-path = "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark";
        font = "${config.gtk.font.name} 12";
        padding = "10,20";
        anchor = "top-right";
        width = 400;
        height = 150;
        border-size = 2;
        background-color = "#${colors.base00}dd";
        border-color = "#${colors.base0A}dd";
        text-color = "#${colors.base05}dd";
        border-radius = 5;
        layer = "overlay";
        max-history = 50;
      };
    };
  };
}
