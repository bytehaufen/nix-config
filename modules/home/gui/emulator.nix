{
  pkgs,
  config,
  lib,
  ...
}: let
  data = config.xdg.dataHome;
in {
  config = lib.mkIf config.opts.home.gui.enable {
    home.sessionVariables = {
      WINEPREFIX = "${data}/wine";
    };

    home.packages = with pkgs; [
      stable.spice-gtk # Spice client for quickemu

      wineWow64Packages.waylandFull # Windows compatibility layer
      winetricks # Windows compatibility layer
    ];
  };
}
