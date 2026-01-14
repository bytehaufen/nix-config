{config, ...}: let
  inherit (config.colorScheme) palette;

  surface = "#${palette.base01}"; # #16161e
  onSurface = "#ffffff";
  onSurfaceVariant = "#${palette.base02}"; # #343a52
  primary = "#${palette.base0A}"; # #0db9d7
  onPrimary = "#${palette.base03}"; # #444b6a
  warning = "#${palette.base0F}"; # #f7768e
  good = "#${palette.base0B}"; # #9ece6a

  border-radius = "${toString (config.programs.waybar.settings.primary.height / 2.0)}";
in
  # css
  ''
    * {
      font-family: "DejaVu Sans", "JetBrainsMono Nerd Font";
      font-size: 12pt;
      padding: 0px;
      margin: 0px 0.4em;
    }

    window#waybar {
      border-radius: ${border-radius};
      background-color: transparent;
      color: ${onSurface};
    }

    .modules-left, .modules-right, .modules-center {
      background-color: ${surface};
      border-radius: ${border-radius};
      padding: 0.1em 0.1em;
    }

    /* modules-left */
    #custom-menu {
      color: ${primary};
      padding-right: 1em;
    }

    #workspaces button {
      background-color: ${surface};
      color: ${onSurface};
    }

    #workspaces button.hidden {
      background-color: ${surface};
      color: ${onSurfaceVariant};
    }
    #workspaces button.focused,
    #workspaces button.active {
      background-color: ${primary};
      color: ${onPrimary};
    }

    /* modules-center */

    /* modules-right */
    #battery.charging {
      color: ${good};
    }

    #battery.warning:not(.charging) {
      color: ${warning};
    }

    #battery.charging.full {
      color: ${warning};
    }

    #custom-hostname {
      color: ${primary};
    }
  ''
