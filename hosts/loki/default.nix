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

  opts.nixos = {
    development.enable = true;
    gui.enable = true;
    home-manager.enable = true;
    location.enable = true;
    printing.enable = true;
    quietboot.enable = true;
    smb.enable = true;
    wireless.enable = true;

    programs = {
      hyprland.enable = true;
      podman.enable = true;
      luanti.enable = true;
      nix-ld.enable = true;
      zsh.enable = true;
    };

    services = {
      kdeconnect.enable = true;
      pipewire.enable = true;
      upower.enable = true;
    };
  };

  networking = {
    hostName = "loki";
    networkmanager.enable = true;
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
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
