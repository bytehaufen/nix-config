{config, ...}: {
  imports = [
    ./core.nix

    # Work specific
    ./work
  ];

  opts.home = {
    tui.enable = true;
    gui.enable = true;
    agenix.enable = true;

    windowManager = {
      niri = {
        enable = true;

        extraConfig = ''
          output "Philips Consumer Electronics Company PHL 278B1 UK02507010538" {
              mode "3840x2160"
              scale 1.5
              position x=0 y=0
          }

          output "Philips Consumer Electronics Company PHL 278B1 UK02507010541" {
              mode "3840x2160"
              scale 1.5
              position x=2560 y=0
              focus-at-startup
          }

          output "eDP-1" {
              mode "1920x1080"
              scale 1.2
              position x=5120 y=0
          }
        '';
      };
    };

    programs = {
      copilot.enable = true;
      ollama.enable = true;
      mcphost.enable = true;
      openai-codex.enable = true;

      discord.enable = true;
      luanti.enable = true;
      nchat.enable = true;
      obs.enable = true;
      teams.enable = true;
    };

    services = {
      kdeconnect.enable = true;
      playerctl.enable = true;
      power-monitor.enable = false; # No auto changing of power profiles
      syncthing.enable = true;
      udiskie.enable = true;
    };

    theme.wallpaper = config.xdg.configHome + "/images/dark-music.jpg";
  };
}
