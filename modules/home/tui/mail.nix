{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    # TODO: Setup correctly -> programs.aerc
    home.packages = [pkgs.thunderbird];
  };
}
