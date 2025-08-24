{
  pkgs,
  config,
  vars,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = false;
  users.users."rico" = {
    hashedPassword = "$6$sPSd4O.QXpNQTOSi$TAkmMKvjCwUWJk0CJDEWWTaOHwQydEvYmIIWMQ3pttHuwQ6ErxrGnMc6kPFgox315g.Wmkojv3bj/R83zJhvp/";
    isNormalUser = true;
    extraGroups = ifTheyExist [
      "audio"
      "docker"
      "git"
      "libvirtd"
      "lxd"
      "mysql"
      "network"
      "podman"
      "video"
      "wheel"
    ];
    openssh.authorizedKeys.keys = vars.sshAuthorizedKeys;

    packages = [pkgs.home-manager];
  };

  home-manager.users = {
    "rico" = {
      programs.home-manager.enable = true;

      home = {
        username = "rico";
        homeDirectory = "/home/rico";
        stateVersion = "25.05";
        extraOutputsToInstall = ["doc" "devdoc"];
      };
      news.display = "silent";
      manual.manpages.enable = true;

      services.syncthing = {
        enable = true;
        # TODO: Continue with the configuration
      };
    };
  };
}
