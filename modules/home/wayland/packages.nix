{
  lib,
  pkgs,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.windowManager.hyprland.enable {
    home.packages = with pkgs; [
      adwaita-icon-theme # Icon theme
      brightnessctl # Brightness control
      dconf # Configuration system
      libsForQt5.qt5ct # Qt5 configuration tool
      libva # Video Acceleration API
      meson # Build system
      morewaita-icon-theme # Icon theme
      networkmanagerapplet # Provide GUI app: nm-connection-editor
      pipewire # Multimedia framework
      qogir-icon-theme # Icon theme
      wayland-utils # Utilities for Wayland
      wayland-protocols # Wayland protocols
      wireplumber # Media session manager for PipeWire
      wlroots # Modular Wayland compositor library
      xwayland # X11 compatibility layer for Wayland
    ];
  };
}
