{
  pkgs,
  config,
  lib,
  ...
}: let
  braveArgs = [
    "--ozone-platform-hint=auto"
    "--password-store=gnome-libsecret"
    "--gtk-version=4"
    "--enable-wayland-ime"
    "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
    "--remote-debugging-port=9222"
  ];

  braveWithArgs = pkgs.brave.overrideAttrs (old: {
    preFixup =
      (old.preFixup or "")
      + ''
        gappsWrapperArgs+=(
          --add-flags ${
          lib.escapeShellArg (lib.concatStringsSep " " braveArgs)
        }
        )
      '';
  });
in {
  config = lib.mkIf config.opts.home.gui.enable {
    programs = {
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };

      brave = {
        enable = true;
        package = braveWithArgs;
      };
    };
  };
}
