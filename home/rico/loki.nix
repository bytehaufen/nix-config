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
    philips1 = {
      name = "DP-5";
      pos = 1;
      width = 2560;
      height = 1440;
      scale = 1;
    };

    philips2 = {
      name = "DP-6";
      pos = 2;
      width = 2560;
      height = 1440;
      scale = 1;
    };
    asus = {
      name = "HDMI-A-1";
      pos = 3;
      width = 2560;
      height = 1080;
      scale = 1;
    };
    display = {
      name = "eDP-1";
      pos = 4;
      width = 1920;
      height = 1080;
      scale = 1.2;
    };

    monitors = [philips1 philips2 asus display];

    mkRes = m: "${toString m.width}x${toString m.height}";
    mkPos = x: "${toString x}x0";
    mkString = m: x: "${m.name}, ${mkRes m}, ${mkPos x}, ${toString m.scale}";

    calcMonitorStrings = ms: let
      sorted = builtins.sort (a: b: a.pos < b.pos) ms;
      state =
        builtins.foldl' (
          st: m: let
            s = mkString m st.x;
            x' = st.x + m.width;
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
      "1, monitor:${philips1.name}, persistent:true"
      "2, monitor:${philips2.name}, persistent:true"
      "3, monitor:${asus.name}, persistent:true"
      "4, monitor:${display.name}, persistent:true"
    ];
  };
}
