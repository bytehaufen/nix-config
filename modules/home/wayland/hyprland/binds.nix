{
  lib,
  config,
  pkgs,
  scripts,
  ...
}: let
  # Binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (builtins.genList (
      x: let
        ws = let
          c = (x + 1) / 10;
        in
          builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    )
    10);

  toggle = program: service: let
    prog = builtins.substring 0 14 program;
    runserv = lib.optionalString service "run-as-service";
  in "pkill ${prog} || ${runserv} ${program}";

  playerctl = lib.getExe pkgs.playerctl;
  makoctl = lib.getExe' config.services.mako.package "makoctl";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  brightnessctl = lib.getExe pkgs.brightnessctl;
in {
  "$mod" = "SUPER";
  # Mouse movements
  bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
    "$mod SHIFT, mouse:272, resizewindow"
  ];

  # Binds
  bind =
    [
      # Compositor commands
      "$mod SHIFT, Q, exit,"
      "$mod, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, G, togglegroup,"
      "$mod SHIFT, N, changegroupactive, f"
      "$mod SHIFT, P, changegroupactive, b"
      "$mod, V, togglefloating, active"
      "$mod, B, exec, hyprctl dispatch togglefloating; hyprctl dispatch layoutmsg swapwithmaster"
      "$mod, P, pseudo,"
      "$mod ALT, ,resizeactive,"
      "$mod,      A, layoutmsg, togglesplit"
      "$mod SHIFT, A, layoutmsg, swapsplit"
      # See the properties of the focused window
      "$mod, I, exec, hyprctl activewindow > /tmp/hyprctl_activewindow && kitty -e zsh -c 'nvim /tmp/hyprctl_activewindow; rm /tmp/hyprctl_activewindow'"

      # Toggle fullscreen
      "$mod, M, fullscreen, toggle"

      # Keybinding to apply monitor settings
      "$mod CTRL,  M, exec,    ${lib.getExe scripts.set-monitors-mirrored}"

      # Terminal
      "$mod, Return, exec, run-as-service ${lib.getExe pkgs.kitty}"

      # Gui
      "$mod, W, exec, ${lib.getExe config.programs.chromium.package}"
      "$mod, E, exec, ${lib.getExe pkgs.nautilus}"

      # Mako
      "$mod, d, exec, ${makoctl} dismiss"
      "$mod SHIFT, d, exec, ${makoctl} restore"

      # Switch keyboard lang
      "$mod, backspace, exec, ${lib.getExe scripts.next-xkb-layout}"

      # Standby screen
      "$mod ALT, l, exec, ${lib.getExe scripts.pause-system}"
      "$mod CTRL ALT, l, exec, systemctl hibernate"

      # Open calculator
      ", XF86Calculator, exec, ${toggle "gnome-calculator" true}"

      # Movement
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, k, movefocus, u"
      "$mod, j, movefocus, d"
      # Move focused window
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"
      "$mod SHIFT, l, movewindow, r"
      # Resize
      "$mod CTRL, h, resizeactive, -40 0"
      "$mod CTRL, l, resizeactive, 40 0"
      "$mod CTRL, k, resizeactive, 0 -40"
      "$mod CTRL, j, resizeactive, 0 40"

      # Go to next window, for example to reach a floating one
      "$mod, space, cyclenext"

      # Special workspace
      "$mod SHIFT, grave, movetoworkspace, special"
      "$mod, grave, togglespecialworkspace, eDP-1"

      # Cycle workspaces
      "$mod, bracketleft, workspace, m-1"
      "$mod, bracketright, workspace, m+1"

      # Move active to next/prev workspace
      "$mod SHIFT, bracketleft, movetoworkspace, r-1"
      "$mod SHIFT, bracketright, movetoworkspace, r+1" # Let create new workspace, when @ the end

      # Cycle monitors
      "$mod CTRL, bracketleft, focusmonitor, l"
      "$mod CTRL, bracketright, focusmonitor, r"

      # Send focused workspace to left/right monitors
      "$mod CTRL SHIFT, bracketleft, movecurrentworkspacetomonitor, l"
      "$mod CTRL SHIFT, bracketright, movecurrentworkspacetomonitor, r"

      # Screen[shot|record]
      "$mod ALT, R, exec, ${lib.getExe scripts.record-area}"
      "$mod ALT, S, exec, ${lib.getExe scripts.screenshot-area}"
    ]
    ++ workspaces;

  bindr = [
    # Launcher
    "$mod, SUPER_L, exec, ${toggle "anyrun" true}"
  ];

  bindl = [
    # Media controls
    ", XF86AudioPlay, exec, ${playerctl} play-pause"
    ", XF86AudioPrev, exec, ${playerctl} previous"
    ", XF86AudioNext, exec, ${playerctl} next"

    # Volume
    ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
  ];

  bindle = [
    # Volume
    ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"
    ", XF86AudioLowerVolume, exec, ${wpctl} set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"

    # Backlight
    ", XF86MonBrightnessUp, exec, ${brightnessctl} set 5%+"
    ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"
  ];
}
