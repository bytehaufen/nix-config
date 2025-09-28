{
  inputs,
  vars,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disko-config.nix
    ./users/${vars.username}.nix
  ];

  networking = {
    hostName = "odin";
    networkmanager.enable = true;
  };

  hardware.graphics.enable = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };

    # For cross-compilation
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "i686-linux"
    ];
  };

  system.stateVersion = "25.05";
}
