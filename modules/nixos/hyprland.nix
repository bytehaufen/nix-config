{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.nixos.gui.enable {
    programs.hyprland = {
      enable = true;

      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
  };
}
