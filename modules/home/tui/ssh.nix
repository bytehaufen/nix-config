{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };

        "github.com" = {
          hostname = "ssh.github.com";
          user = "git";
          identityFile = config.age.secrets.id_ed25519_github.path;
          identitiesOnly = true;
          addKeysToAgent = "yes";
        };
      };
    };

    services.ssh-agent.enable = true;
  };
}
