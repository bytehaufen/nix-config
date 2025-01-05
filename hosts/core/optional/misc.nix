{pkgs, ...}: {
  services = {
    printing.enable = true; # Enable CUPS to print documents.
    geoclue2.enable = true; # Enable geolocation services.

    udev.packages = with pkgs; [
      gnome-settings-daemon
      platformio # Udev rules for platformio
      openocd # Required by paltformio, see https://github.com/NixOS/nixpkgs/issues/224895
      android-udev-rules # Required by adb
    ];
  };
}
