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
        theme = "tokyonight_night"; # Setting theme here does not work
      };
      extraPackages = with pkgs.bat-extras; [batdiff batwatch];
    };

    xdg.configFile."bat/themes/tokyonight_night.tmTheme".source = ./tokyonight_night.tmTheme;
  };
}
