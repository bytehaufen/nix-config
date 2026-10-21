{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # Work time tracking
    workaholick
  ];

  xdg.configFile = let
    workaholickDirectory = "${config.home.homeDirectory}/nix-config/modules/home/tui/workaholick";
  in {
    "workaholick/config.toml" .
        source = config.lib.file.mkOutOfStoreSymlink "${workaholickDirectory}/config.toml";
  };
}
