{
  imports = [
    ./core.nix

    # Work specific
    ./work
  ];

  opts.home = {
    tui.enable = true;
    gui.enable = true;
    agenix.enable = true;
    windowManager.hyprland.enable = true;

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
  };

  wayland.windowManager.hyprland.settings = let
    # Use stable monitor descriptions instead of connector names, which can
    # change across kernel/Hyprland updates and different dock states.
    philips1 = {
      desc = "desc:Philips Consumer Electronics Company PHL 278B1 UK02507010538";
      pos = 1;
      width = 3840;
      height = 2160;
      scale = 1.5;
    };

    philips2 = {
      desc = "desc:Philips Consumer Electronics Company PHL 278B1 UK02507010541";
      pos = 2;
      width = 3840;
      height = 2160;
      scale = 1.5;
    };
    display = {
      desc = "desc:LG Display 0x072C";
      pos = 3;
      width = 1920;
      height = 1080;
      scale = 1.2;
    };

    monitors = [philips1 philips2 display];

    mkRes = m: "${toString m.width}x${toString m.height}";
    mkPos = x: "${toString x}x0";
    mkString = m: x: "${m.desc}, ${mkRes m}, ${mkPos x}, ${toString m.scale}";
    logicalWidth = m: builtins.floor (m.width / m.scale);

    calcMonitorStrings = ms: let
      sorted = builtins.sort (a: b: a.pos < b.pos) ms;
      state =
        builtins.foldl' (
          st: m: let
            s = mkString m st.x;
            x' = st.x + logicalWidth m;
          in {
            x = x';
            acc = st.acc ++ [s];
          }
        ) {
          x = 0;
          acc = [];
        }
        sorted;
    in
      state.acc;
  in {
    monitor = calcMonitorStrings monitors;
    workspace = [
      "1, monitor:${philips1.desc}, persistent:true"
      "2, monitor:${philips2.desc}, persistent:true"
      "3, monitor:${display.desc}, persistent:true"
    ];
  };
}
