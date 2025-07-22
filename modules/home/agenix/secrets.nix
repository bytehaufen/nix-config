{
  lib,
  config,
  inputs,
  ...
}: {
  config = lib.mkIf config.opts.home.agenix.enable {
    age = {
      secrets = {
        "id_ed25519_github" = {
          file = "${inputs.secrets}/id_ed25519_github.age";
          mode = "0400";
        };

        "id_ed25519_github.pub" = {
          file = "${inputs.secrets}/id_ed25519_github.pub.age";
          mode = "0400";
        };

        "id_ed25519_rico_work" = {
          file = "${inputs.secrets}/id_ed25519_rico_work.age";
          mode = "0400";
        };

        "smb-secrets" = {
          file = "${inputs.secrets}/smb-secrets.age";
          mode = "0400";
        };

        "ssh-config-work" = {
          file = "${inputs.secrets}/ssh-config-work.age";
          mode = "0400";
        };
      };
    };
  };
}
