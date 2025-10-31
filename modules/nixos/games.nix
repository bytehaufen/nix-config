{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.nixos.programs.luanti.enable {
    networking.firewall = {
      allowedUDPPortRanges = [
        {
          from = 30000;
          to = 30004;
        }
      ];
      allowedTCPPortRanges = [
        {
          from = 30000;
          to = 30004;
        }
      ];
    };
  };
}
