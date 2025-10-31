{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.programs.luanti.enable {
    home.packages = with pkgs; [
      luanti
    ];
  };
}
