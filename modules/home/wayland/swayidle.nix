{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.windowManager.niri.enable {
    services.swayidle = let
      niri = lib.getExe pkgs.niri;
      swaylock = lib.getExe config.programs.swaylock.package;
      systemctl = lib.getExe' pkgs.systemd "systemctl";

      lockTime = 5 * 60; # 5 minutes
      monitorOffTime = lockTime + 60; # 6 minutes
      suspendTime = 2 * lockTime; # 10 minutes
    in {
      enable = true;
      systemdTargets = ["graphical-session.target"];
      timeouts = [
        # Lock screen
        {
          timeout = lockTime;
          command = "${swaylock} --daemonize";
        }

        # Turn off displays
        {
          timeout = monitorOffTime;
          command = "${niri} msg action power-off-monitors";
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
