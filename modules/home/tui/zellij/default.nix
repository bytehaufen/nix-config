{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
    };
    xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  };
}
