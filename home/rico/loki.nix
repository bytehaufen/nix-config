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

    windowManager.niri = {
      enable = true;

      monitorProfiles = {
        home = {
          m1 = {
            criteria = "Philips Consumer Electronics Company PHL 278B1 UK02507010538";
            mode = "3840x2160";
            scale = 1.5;
            position = "0,0";
          };
          m2 = {
            criteria = "Philips Consumer Electronics Company PHL 278B1 UK02507010541";
            mode = "3840x2160";
            scale = 1.5;
            position = "2560,0";
            focus = true;
          };
          m3 = {
            criteria = "eDP-1";
            mode = "1920x1080";
            scale = 1.2;
            position = "5120,0";
          };
        };

        undocked.m3 = {
          criteria = "eDP-1";
          mode = "1920x1080";
          scale = 1.2;
          position = "0,0";
        };
      };
    };

    programs = {
      copilot.enable = true;
      ollama.enable = true;
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
