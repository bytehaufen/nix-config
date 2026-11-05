{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        tabs = "2";
      };
      extraPackages = with pkgs.bat-extras; [batdiff batwatch];
    };
  };
}
