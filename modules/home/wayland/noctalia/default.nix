{
  pkgs,
  config,
  ...
}: let
  package = pkgs.noctalia-shell;
in {
  home.packages = [
    package
    pkgs.app2unit # Launch Desktop Entries (or arbitrary commands) as Systemd user units
  ];

  xdg.configFile = let
    mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    confPath = "${config.home.homeDirectory}/nix-config/modules/home/wayland/noctalia";
  in {
    # NOTE: use config dir as noctalia config because config is not only settings.json
    # https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix#L211-L220
    "noctalia".source = mkSymlink "${confPath}/config";
  };
}
