{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
in {
  imports = [
    inputs.agenix.homeManagerModules.default
    ./secrets.nix
  ];

  config = lib.mkIf config.opts.home.agenix.enable {
    home.packages = [pkgs.ragenix];

    age = {
      identityPaths = ["${home}/.ssh/id_ed25519_rico"];
      secretsDir = "${home}/.agenix/agenix";
      secretsMountPoint = "${home}/.agenix/agenix.d";
    };
  };
}
