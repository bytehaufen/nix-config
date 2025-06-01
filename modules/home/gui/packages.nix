{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.opts.gui.enable {
    home.packages = with pkgs; [
      gnome-calculator # Calculator
      keepassxc # Password manager
      mission-center # System monitor
      nautilus # File manager
      overskride # Bluetooth / Obex client
      vimiv-qt # Image viewer

      # Screenshot
      grim # Screenshot utility
      grimblast # Screenshot utility with clipboard support
      slurp # Select screen area for screenshots
      swappy # Image annotation tool

      # Utilities
      wl-clipboard # Clipboard utilities for Wayland
      wl-screenrec # Screen recording utility for Wayland
      wlr-randr # Wayland screen management utility
    ];
  };
}
