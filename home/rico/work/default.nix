{config, ...}: let
  identityFile = config.age.secrets.id_ed25519_rico_work.path;
in {
  imports = [./packages.nix];

  programs.ssh = {
    includes = [config.age.secrets.ssh-config-work.path];
    extraConfig = ''
      Host confluence-tunnel jira-tunnel gitlab-tunnel podman-registry-tunnel bender3 leela2 zoidberg leela kif elzar amy3 amy4 zapp zapp2 zappext svn-extern jenkins morbo nas smithers flanders svn
        AddKeysToAgent yes
        IdentityFile ${identityFile}
    '';
  };
}
