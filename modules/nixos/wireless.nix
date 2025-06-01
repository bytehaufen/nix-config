{
  lib,
  config,
  ...
}: {
  hardware.bluetooth = {
    enable = true;
  };

  services.blueman.enable = true;

  # Wireless networking is enabled by `networking.networkmanager`

  # Ensure group exists
  users.groups.network = {};

  networking.networkmanager.wifi.powersave = lib.mkIf config.networking.networkmanager.enable false;
}
