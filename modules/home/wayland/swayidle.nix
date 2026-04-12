{
  pkgs,
  lib,
  config,
  ...
}: let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
  swaylock = lib.getExe config.programs.swaylock.package;
  systemctl = lib.getExe' pkgs.systemd "systemctl";

  lockTime = 5 * 60; # 5 minutes
  monitorOffTime = lockTime + 60; # 6 minutes
  suspendTime = 2 * lockTime; # 10 minutes
in {
  config = lib.mkIf config.opts.home.windowManager.hyprland.enable {
    services.swayidle = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
      timeouts = [
        # Lock screen
        {
          timeout = lockTime;
          command = "${swaylock} --daemonize";
        }

        # Turn off displays (hyprland)
        {
          timeout = monitorOffTime;
          command = "${hyprctl} dispatch dpms off";
          resumeCommand = "${hyprctl} dispatch dpms on;";
        }

        # Let system sleep
        {
          timeout = suspendTime;
          command = "${systemctl} suspend";
        }
      ];
    };
  };
}
