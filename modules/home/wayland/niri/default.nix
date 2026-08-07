{
  pkgs,
  config,
  lib,
  ...
} @ args: let
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

  scripts = import ../scripts.nix args;

  playerctl = lib.getExe pkgs.playerctl;
  makoctl = lib.getExe' config.services.mako.package "makoctl";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  brightnessctl = lib.getExe pkgs.brightnessctl;
in {
  imports = [./standalone.nix];

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

      layout {
          focus-ring {
              active-color "#${config.colorScheme.palette.base0A}"
              inactive-color "#${config.colorScheme.palette.base03}"
          }
      }

      spawn-at-startup "${lib.getExe pkgs.swaybg}" "-m" "fill" "-i" "${config.opts.home.theme.wallpaper}"
      spawn-at-startup "${pkgs.networkmanagerapplet}/bin/nm-applet"
      spawn-at-startup "${pkgs.blueman}/bin/blueman-applet"

      binds {
          Mod+Return { spawn "sh" "-c" "run-as-service ${lib.getExe pkgs.kitty}"; }
          Mod+W { spawn "${lib.getExe config.programs.chromium.package}"; }
          Mod+E { spawn "${lib.getExe pkgs.nautilus}"; }

          Mod+Space { spawn "sh" "-c" "pkill anyrun || run-as-service ${lib.getExe config.programs.anyrun.package}"; }

          Mod+D { spawn "${makoctl}" "dismiss"; }
          Mod+Shift+D { spawn "${makoctl}" "restore"; }

          Mod+BackSpace { spawn "${lib.getExe scripts.next-xkb-layout}"; }

          Mod+Alt+L { spawn "${lib.getExe scripts.pause-system}"; }
          Mod+Ctrl+Alt+L { spawn "${lib.getExe' pkgs.systemd "systemctl"}" "hibernate"; }

          Mod+Alt+R { spawn "${lib.getExe scripts.record-area}"; }
          Mod+Alt+S { spawn "${lib.getExe scripts.screenshot-area}"; }

          XF86AudioPlay allow-when-locked=true { spawn "${playerctl}" "play-pause"; }
          XF86AudioPrev allow-when-locked=true { spawn "${playerctl}" "previous"; }
          XF86AudioNext allow-when-locked=true { spawn "${playerctl}" "next"; }

          XF86AudioMute allow-when-locked=true { spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
          XF86AudioRaiseVolume allow-when-locked=true { spawn "${wpctl}" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "6%+"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn "${wpctl}" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "6%-"; }

          XF86MonBrightnessUp allow-when-locked=true { spawn "${brightnessctl}" "set" "5%+"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "${brightnessctl}" "set" "5%-"; }
      }

      ${cfg.extraConfig}
    '';
  };
}
