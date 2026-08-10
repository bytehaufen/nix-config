{
  imports = [
    ./core.nix
    ./work
  ];

  opts.home = {
    tui.enable = true;
    gui.enable = true;
    agenix.enable = true;
    windowManager.niri = {
      enable = true;
      extraConfig = ''
        debug {
            // render-drm-device "/dev/dri/renderD129"
            wait-for-frame-completion-before-queueing
        }
      '';
    };

    programs = {
      copilot.enable = false;
      ollama-cuda.enable = true;
      openai-codex.enable = true;

      discord.enable = false;
      nchat.enable = true;
      obs.enable = false;
      teams.enable = true;
    };

    services = {
      kdeconnect.enable = false;
      playerctl.enable = false;
      power-monitor.enable = false;
      syncthing.enable = true;
      udiskie.enable = false;
    };
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
  };

  targets.genericLinux.gpu.nvidia = {
    enable = true;
    # Query the version:
    # nvidia-smi --query-gpu=driver_version --format=csv,noheader
    version = "595.71.05";
    # From home-manager options:
    # nix store prefetch-file https://download.nvidia.com/XFree86/Linux-x86_64/@VERSION@/NVIDIA-Linux-x86_64-@VERSION@.run
    # where @VERSION@ is replaced with the exact driver version.
    # If you are on ARM, replace Linux-x86_64 with Linux-aarch64.
    sha256 = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
  };

  services.kanshi = {
    enable = true;

    settings = [
      {
        profile = {
          name = "home";

          outputs = [
            {
              criteria = "Philips Consumer Electronics Company PHL 278B1 UK02507010538";
              status = "enable";
              scale = 1.5;
              position = "0,0";
            }
            {
              criteria = "Philips Consumer Electronics Company PHL 278B1 UK02507010541";
              status = "enable";
              scale = 1.5;
              position = "2560,0";
            }
            {
              criteria = "BOE NE160QDM-NZC Unknown";
              status = "enable";
              scale = 1.5;
              position = "5120,0";
            }
          ];
        };
      }

      {
        profile = {
          name = "office";

          outputs = [
            {
              criteria = "Lenovo Group Limited LEN LT2452pwC 0x4B355A33";
              status = "enable";
              mode = "1920x1200@59.950Hz";
              position = "0,0";
              scale = 1.0;
              transform = "normal";
            }

            {
              criteria = "Lenovo Group Limited LEN LT2452pwC 0x4E395A33";
              status = "enable";
              mode = "1920x1200@59.950Hz";
              position = "1920,0";
              scale = 1.0;
              transform = "normal";
            }

            {
              criteria = "BOE NE160QDM-NZC Unknown";
              status = "enable";
              mode = "2560x1600@240.000Hz";
              position = "3840,0";
              scale = 1.5;
              transform = "normal";
            }
          ];
        };
      }
    ];
  };
}
