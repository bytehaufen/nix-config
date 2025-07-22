{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.skim = {
      enable = true;
      enableZshIntegration = true;

      defaultCommand = "rg --files --hidden";

      changeDirWidgetOptions = [
        "--preview 'eza --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };
}
