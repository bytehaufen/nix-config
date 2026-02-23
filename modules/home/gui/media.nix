{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.opts.home.gui.enable {
    home.packages = with pkgs; [
      pulsemixer # PulseAudio mixer
      pavucontrol # PulseAudio volume control
      spotube # Spotify client
      musicpod # YT Music client
    ];

    programs = {
      zsh.shellAliases = {pulse = "pulsemixer";};

      mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [
          pkgs.mpvScripts.mpris # Control mpv with standard media keys
        ];
        config = {
          keep-open = true;
        };
        bindings = {
          "Alt+RIGHT" = "no-osd cycle-values video-rotate  '90' '180' '270' '0'";
          "Alt+LEFT" = "no-osd cycle-values video-rotate  '270' '180' '90' '0'";
        };
      };
    };
  };
}
