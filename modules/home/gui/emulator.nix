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
      # Upstream mostly broken
      quickemu # Emulator manager
      quickgui # Quickemu frontend
      stable.spice-gtk # Spice client for quickemu

      stable.wineWowPackages.waylandFull # Windows compatibility layer
      stable.winetricks # Windows compatibility layer
      stable.distrobox
    ];

    xdg.configFile."distrobox/distrobox.conf".text = ''
      container_additional_volumes="/nix/store:/nix/store:ro /etc/static/profiles/per-user:/etc/profiles/per-user:ro"
    '';
  };
}
