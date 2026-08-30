{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.opts.home.windowManager.niri;

  # Used during pure Nix evaluation.
  linkedSource = ./linked;
  linkedTarget = "${config.home.homeDirectory}/nix-config/modules/home/wayland/niri/linked";
  linkedEntries = builtins.readDir linkedSource;
  linkedFiles =
    builtins.filter
    (name:
      lib.hasSuffix ".kdl" name
      && builtins.elem linkedEntries.${name} ["regular" "symlink"])
    (builtins.attrNames linkedEntries);
  linkedIncludes =
    lib.concatMapStringsSep "\n"
    (name: ''include "linked/${name}"'')
    linkedFiles;
in {
  imports = [
    ./monitors.nix
    ./standalone.nix
    ./workspaces.nix
  ];

  config = lib.mkIf cfg.enable {
    home = {
      file.".wayland-session" = {
        text = ''
          #!${pkgs.runtimeShell}
          exec ${lib.getExe' pkgs.niri "niri-session"}
        '';
        executable = true;
      };

      sessionVariables = {
        GTK_USE_PORTAL = 1;
        NIXOS_OZONE_WL = 1;
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";

        # LIBVA_DRIVER_NAME = "iHD";
        MOZ_ENABLE_WAYLAND = "1";

        # NOTE: Check obsolete?
        # WLR_DRM_NO_MODIFIERS = "1";
      };
    };

    xdg.configFile."niri/linked".source = config.lib.file.mkOutOfStoreSymlink linkedTarget;
    xdg.configFile."niri/config.kdl".text = ''
      ${linkedIncludes}

      ${cfg.extraConfig}
    '';
  };
}
