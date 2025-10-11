{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.programs.copilot.enable {
    home.packages = with pkgs; [
      github-copilot-cli
    ];
  };
}
