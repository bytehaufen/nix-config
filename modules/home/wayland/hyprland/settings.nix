{
  pkgs,
  lib,
  config,
  ...
}: let
  rgba = color: alpha: "rgba(${lib.removePrefix "#" color}${alpha})";
in {
  exec-once = [
    "${lib.getExe pkgs.swaybg} -m fill -i ${config.opts.home.theme.wallpaper}"
    "${pkgs.networkmanagerapplet}/bin/nm-applet"
    "${pkgs.blueman}/bin/blueman-applet"
  ];

  env = [
    "NIXOS_OZONE_WL,1" # For any ozone-based browser & electron apps to run on Wayland
    "MOZ_ENABLE_WAYLAND,1" # For Firefox to run on Wayland
    "MOZ_WEBRENDER,1"
    # Misc
    "_JAVA_AWT_WM_NONREPARENTING,1"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
    "QT_QPA_PLATFORM,wayland"
    "SDL_VIDEODRIVER,wayland"
    "GDK_BACKEND,wayland"
    "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
  ];

  general = {
    layout = "master";
    resize_on_border = true;

    gaps_in = 10;
    gaps_out = 10;
    border_size = 2;
    "col.active_border" = "${rgba config.colorScheme.palette.base0A "aa"} ${rgba config.colorScheme.palette.base05 "aa"}";
    "col.inactive_border" = "${rgba config.colorScheme.palette.base0A "77"} ${rgba config.colorScheme.palette.base05 "77"}";
  };

  decoration = {
    active_opacity = 1.0;
    inactive_opacity = 0.85;
    fullscreen_opacity = 1.0;
    rounding = 7;
    blur = {
      enabled = true;
      size = 4;
      passes = 3;
      new_optimizations = true;
      ignore_opacity = true;
      popups = true;
    };
    shadow = {
      enabled = true;
      offset = "3 3";
      range = 12;
      color = "0x44000000";
      color_inactive = "0x66000000";
    };
  };

  animations = {
    enabled = true;
    bezier = [
      "easein,0.1, 0, 0.5, 0"
      "easeinback,0.35, 0, 0.95, -0.3"

      "easeout,0.5, 1, 0.9, 1"
      "easeoutback,0.35, 1.35, 0.65, 1"

      "easeinout,0.45, 0, 0.55, 1"
    ];

    animation = [
      "fadeIn,1,3,easeout"
      "fadeLayersIn,1,3,easeoutback"
      "layersIn,1,3,easeoutback,slide"
      "windowsIn,1,3,easeoutback,slide"

      "fadeLayersOut,1,3,easeinback"
      "fadeOut,1,3,easein"
      "layersOut,1,3,easeinback,slide"
      "windowsOut,1,3,easeinback,slide"

      "border,1,3,easeout"
      "fadeDim,1,3,easeinout"
      "fadeShadow,1,3,easeinout"
      "fadeSwitch,1,3,easeinout"
      "windowsMove,1,3,easeoutback"
      "workspaces,1,2.6,easeoutback,slide"
    ];
  };

  input = {
    # FIXME: Need to move to nix conf
    # Custom keyboard layout defined in ~/.config/xkb/symbols/
    kb_layout = "en-65,de-65";
    kb_options = "caps:escape";

    numlock_by_default = true;
    repeat_delay = 300;
    repeat_rate = 60;
    follow_mouse = true;
    float_switch_override_focus = 0;

    accel_profile = "flat";
    touchpad = {
      natural_scroll = true;
    };
  };

  # Unused -> set to master layout
  dwindle = {
    pseudotile = true;
    preserve_split = true;
  };

  misc = {
    # disable auto polling for config file changes
    disable_autoreload = true;

    force_default_wallpaper = 0;

    # disable dragging animation
    animate_mouse_windowdragging = false;

    # enable variable refresh rate (effective depending on hardware)
    vfr = true;
    vrr = false;

    # Do not show ANR Dialog when a window is unresponsive
    enable_anr_dialog = false;
  };

  # touchpad gestures
  gesture = "3, horizontal, workspace";

  xwayland.force_zero_scaling = true;

  debug.disable_logs = false;

  ecosystem = {
    no_update_news = true;
  };
}
