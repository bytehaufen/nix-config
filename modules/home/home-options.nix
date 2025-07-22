{
  lib,
  config,
  ...
}: let
  mkEnableOption = desc: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = desc;
    };
  };
in {
  options.opts.home = {
    tui = mkEnableOption "Enable TUI applications in the home environment";
    gui = mkEnableOption "Enable GUI applications in the home environment";
    nixGL = mkEnableOption "Enable NixGL, the wrapper for OpenGL applications in non-NixOS";
    windowManager.hyprland = mkEnableOption "Enable Hyprland, a dynamic tiling Wayland compositor";

    programs = {
      discord = mkEnableOption "Enable Discord Vesktop Client";
      minetest = mkEnableOption "Enable Minetest, an open source voxel game engine";
      nchat = mkEnableOption "Enable nchat - Terminal-based chat client with support for Telegram and WhatsApp";
      obs = mkEnableOption "Enable OBS Studio configuration.";
      teams = mkEnableOption "Enable Microsoft Teams Client for Linux";
    };

    services = {
      kdeconnect = mkEnableOption "Enable KDE Connect, a tool to integrate your phone with your desktop";
      playerctl = mkEnableOption "Enable playerctl, a command-line utility to control media players";
      power-monitor = mkEnableOption "Enable power-monitor, a tool to monitor power usage and battery status";
      syncthing = mkEnableOption "Enable Syncthing, a continuous file synchronization program";
      udiskie = mkEnableOption "Enable udiskie, a tool to manage removable drives in Wayland";
    };

    theme.wallpaper = lib.mkOption {
      description = "Location of the wallpaper to use throughout the system";
      type = lib.types.path;
      example = lib.literalExample "/home/foobar/.config/wallpaper/wallpaper.png";
      default = config.xdg.configHome + "/images/hyprland.png";
    };
  };
}
