{
  pkgs,
  lib,
  config,
  outputs,
  isStandalone ? false,
  ...
}: {
  config = lib.mkIf isStandalone {
    # Better home-manager integration on non-NixOS
    # Sets environment variables lie XDG_DATA_DIRS and fixing locale issues
    targets.genericLinux.enable = true;

    # Create `.profile` to source home-manager session vars on non-nixos
    home.file.".profile".text = ''
      . ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh
    '';

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        allowUnsupportedSystem = true;
        experimental-features = "nix-command flakes ca-derivations";
      };
    };

    # NOTE: On Non-NixOS systems, the user needs to have the access rights to the nix daemon.
    # So add "trusted-users = foo" to `/etc/nix/nix.conf` for user foo.
    # Restart nix daemon `sudo systemctl restart nix-daemon.service`
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        substituters = [
          "https://hyprland.cachix.org"
        ];
        extra-substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];
        accept-flake-config = true;
        warn-dirty = false;
      };
    };
  };
}
