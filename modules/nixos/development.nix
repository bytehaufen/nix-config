{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.nixos.development.enable {
    services = {
      udev.packages = with pkgs; [
        platformio # Udev rules for platformio
        openocd # Required by paltformio, see https://github.com/NixOS/nixpkgs/issues/224895
      ];
    };
  };
}
