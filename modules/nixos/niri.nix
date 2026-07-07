{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.nixos.programs.niri.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };
}
