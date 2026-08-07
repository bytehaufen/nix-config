{
  pkgs,
  isStandalone,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.windowManager.niri.enable {
    wayland.windowManager.niri = {
      enable = isStandalone;
    };

    xdg.portal.extraPortals = lib.optionals isStandalone [pkgs.xdg-desktop-portal-gtk];
    services.gnome-keyring.enable = isStandalone;

    systemd.user.services.polkit-gnome = lib.mkIf isStandalone {
      Unit = {
        Description = "PolicyKit Authentication Agent";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
