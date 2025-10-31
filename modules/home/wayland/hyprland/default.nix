{
  pkgs,
  config,
  lib,
  inputs,
  ...
} @ args: let
  # Custom scripts, used in keybindings and in user environment
  scripts = import ./scripts.nix args;

  # Hyprland settings consist of a set of keybindings and other configurations
  settings = lib.mkMerge [
    (import ./settings.nix args)
    (import ./binds.nix (args // {inherit scripts;}))
    (import ./rules.nix args)
  ];
in {
  config = lib.mkIf config.opts.home.windowManager.hyprland.enable {
    # Propagate all scripts to the user env to make them available in the shell
    home = {
      packages = [pkgs.swaybg] ++ builtins.attrValues scripts;
      file.".wayland-session" = {
        source = "${lib.getExe pkgs.hyprland}";
        executable = true;
      };

      sessionVariables = {
        GTK_USE_PORTAL = 1;
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        XDG_SESSION_TYPE = "wayland";

        LIBVA_DRIVER_NAME = "iHD";
        MOZ_ENABLE_WAYLAND = "1";
        WLR_DRM_NO_MODIFIERS = "1";
      };
    };

    programs.zsh.shellAliases = {
      xkill = "${lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl"} kill";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];

      config = {
        common = {
          default = [
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = [
            "gnome-keyring"
          ];
        };
        hyprland.default = ["gtk" "wlr"];
      };
    };

    wayland.windowManager.hyprland = let
      hPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
    in {
      inherit settings;

      # package = config.lib.nixGL.wrap (pkgs.hyprland.override {wrapRuntimeDeps = false;});
      enable = true;
      package = config.lib.nixGL.wrap (hPackage.hyprland.override {wrapRuntimeDeps = false;});
      portalPackage = hPackage.xdg-desktop-portal-hyprland;
      systemd = {
        enable = true;
        variables = ["--all"];
      };

      xwayland.enable = true;
    };
  };
}
