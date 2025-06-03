{lib, ...}: let
  mkEnableOption = desc: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = desc;
    };
  };
in {
  options.opts.nixos = {
    gui = mkEnableOption "Enable GUI applications in the nixos";
    home-manager = mkEnableOption "Enable Home Manager for user configuration management";
    location = mkEnableOption "Enable location services for geolocation support";
    quietboot = mkEnableOption "Enable quiet boot mode to reduce boot messages";
    smb = mkEnableOption "Enable SMB/CIFS file sharing support";
    wireless = mkEnableOption "Enable wireless networking support";

    programs = {
      hyprland = mkEnableOption "Enable Hyprland as the window manager";
      podman = mkEnableOption "Enable Podman for container management";
      nix-ld = mkEnableOption "Enable Nix-LD for dynamic linking with Nix packages";
    };

    services = {
      kdeconnect = mkEnableOption "Enable KDE Connect service for device integration";
      pipewire = mkEnableOption "Enable PipeWire for audio and video handling";
      upower = mkEnableOption "Enable UPower service for power management";
    };
  };
}
