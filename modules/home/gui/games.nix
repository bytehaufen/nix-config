{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.programs.minetest.enable {
    home.packages = with pkgs; [
      minetest
    ];
  };
}
