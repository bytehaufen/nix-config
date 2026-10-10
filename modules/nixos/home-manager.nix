{
  lib,
  config,
  inputs,
  ...
}: {
  # TODO: Move all global home-manager configuration to here; move imports into `if`
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  config = lib.mkIf config.opts.nixos.home-manager.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = false;
    };
  };
}
