{
  pkgs,
  config,
  lib,
  vars,
  ...
}: {
  config = lib.mkIf config.opts.nixos.smb.enable {
    # For mount.cifs, required unless domain name resolution is not needed.
    environment.systemPackages = [pkgs.cifs-utils];

    fileSystems."/mnt/NAS" = {
      device = "//192.168.178.100/NAS";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=${config.age.secrets.smb-secrets.path}"
        "uid=${toString config.users.users.${vars.username}.uid}"
        "gid=${toString config.users.groups.${config.users.users.${vars.username}.group}.gid}"
      ];
    };

    services.gvfs = {
      enable = true;
      package = lib.mkForce pkgs.gnome.gvfs;
    };
  };
}
