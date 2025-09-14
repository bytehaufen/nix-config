{config, ...}: {
  programs.ssh = {
    enable = true;

    matchBlocks = {
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
}
