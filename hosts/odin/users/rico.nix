{
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
  };

  containers = {
    syncthing-rico = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.250.1.1";
      localAddress = "10.250.1.2";
      forwardPorts = [
        {
          containerPort = 8384;
          hostPort = 8384;
          protocol = "tcp";
        }
      ];
      config = {lib, ...}: {
        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
        };
        networking = {
          firewall.enable = true;
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };
        system.stateVersion = "25.05";
      };
    };

    syncthing-steffen = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.250.2.1";
      localAddress = "10.250.2.2";
      forwardPorts = [
        {
          containerPort = 8384;
          hostPort = 8385;
          protocol = "tcp";
        }
      ];
      config = {lib, ...}: {
        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
        };
        networking = {
          firewall.enable = true;
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };
        system.stateVersion = "25.05";
      };
    };

    syncthing-maika = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.250.3.1";
      localAddress = "10.250.3.2";
      forwardPorts = [
        {
          containerPort = 8384;
          hostPort = 8386;
          protocol = "tcp";
        }
      ];
      config = {lib, ...}: {
        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
        };
        networking = {
          firewall.enable = true;
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };
        system.stateVersion = "25.05";
      };
    };
  };
}
