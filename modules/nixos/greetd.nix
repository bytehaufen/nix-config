{
  lib,
  config,
  vars,
  ...
}: let
  wmEnabled =
    config.opts.nixos.programs.niri.enable;
in {
  config = lib.mkIf wmEnabled {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          user = vars.username;

          command = "$HOME/.wayland-session"; # Start a wayland session directly without a login manager
        };
      };
    };
  };
}
