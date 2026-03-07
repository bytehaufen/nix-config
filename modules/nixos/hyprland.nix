{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  config = lib.mkIf config.opts.nixos.gui.enable {
    programs.hyprland = {
      enable = true;

      package = inputs.hyprland.packages.${system}.hyprland;
      portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    };

    environment.systemPackages = [
      inputs.hyprland.inputs.hyprland-guiutils.packages.${system}.default
    ];
  };
}
