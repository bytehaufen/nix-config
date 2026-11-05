{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.btop = {
      enable = true;
      settings = {
        vim_keys = true;
        theme_background = false;
      };
    };
  };
}
