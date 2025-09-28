{
  pkgs,
  config,
  vars,
  self,
  ...
}: let
  inherit (vars) username;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = false;
  users.users.${username} = {
    uid = 1000;
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

  home-manager.users.${username}.imports = [
    "${self}/modules/home"
    "${self}/home/${username}/${config.networking.hostName}.nix"
  ];

  security.pam.services = {
    swaylock = {};
  };
}
