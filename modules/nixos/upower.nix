{
  lib,
  config,
  ...
}: let
  hibernatePercentage = 7;
in {
  config = lib.mkIf config.opts.nixos.services.upower.enable {
    services = {
      power-profiles-daemon = {
        enable = true;
      };
      # DBus service that provides power management support to applications
      upower = {
        enable = true;
        percentageCritical = 10;
        criticalPowerAction = "Hibernate";
        percentageAction = hibernatePercentage;
      };
    };
  };
}
