{lib, ...}: {
  # Layer rules
  layerrule = let
    toRegex = list: let
      elements = lib.concatStringsSep "|" list;
    in "^(${elements})$";

    lowopacity = [
      "bar"
      "calendar"
      "notifications"
      "system-menu"
    ];

    highopacity = [
      "osd"
      "logout_dialog"
    ];

    blurred = lib.concatLists [
      lowopacity
      highopacity
    ];
  in [
    "blur on, match:namespace ${toRegex blurred}"
    "xray on, match:namespace ${toRegex ["bar"]}"
  ];

  # Window rules
  windowrule = [
    # Gnome calculator
    "float on, match:class ^(org[.]gnome[.]Calculator)$"

    # Quickgui (Quickemu)
    "float on, match:class ^(quickgui)$"
    "move (monitor_w-window_w-20) window_y, match:class ^(quickgui)$"
    "float on, match:class ^(spicy)$"
    "size 800 600, match:class ^(spicy)$"

    # Allow tearing in games
    "immediate on, match:class ^(osu!|cs2)$"

    # Make Firefox PiP window floating and sticky
    "float on, match:title ^(Picture-in-Picture)$"
    "pin on, match:title ^(Picture-in-Picture)$"

    # Throw sharing indicators away
    "workspace special silent, match:title ^(Firefox — Sharing Indicator)$"
    "workspace special silent, match:title ^(.*is sharing (your screen|a window)[.])$"

    # Idle inhibit while watching videos
    "idle_inhibit focus, match:class ^(mpv|.+exe|celluloid)$"
    "idle_inhibit focus, match:class ^(brave-browser)$, match:title ^(.*YouTube.*)$"
    "idle_inhibit fullscreen, match:class ^(brave-browser)$"
    "idle_inhibit focus, match:class ^(firefox)$, match:title ^(.*YouTube.*)$"
    "idle_inhibit fullscreen, match:class ^(firefox)$"

    # Do not go idle while anything is fullscreen
    "idle_inhibit fullscreen, match:class ^(kitty.*)$"

    # Musicpod
    "float on, match:class ^(musicpod)$"
    "size 500 700, match:class ^(musicpod)$"
    "monitor 0, match:class ^(musicpod)$"
    "move (monitor_w-window_w-20) window_y, match:class ^(musicpod)$"

    # Gpt4all
    "float on, match:class ^(io[.]gpt4all[.].*)$"
    "size 1280 720, match:class ^(io[.]gpt4all[.].*)$"
    "move (monitor_w-window_w-20) window_y, match:class ^(io[.]gpt4all[.].*)$"

    "dim_around on, match:class ^(gcr-prompter)$"
    "dim_around on, match:class ^(xdg-desktop-portal-gtk)$"
    "dim_around on, match:class ^(polkit-gnome-authentication-agent-1)$"

    # Fix xwayland apps
    "rounding 0, match:xwayland true"
    "center on, match:class ^(.*jetbrains.*)$, match:title ^(Confirm Exit|Open Project|win424|win201|splash)$"
    "size 640 400, match:class ^(.*jetbrains.*)$, match:title ^(splash)$"

    # File / directory chooser
    "float on, match:title ^(Open File)(.*)$"
    "size 640 480, match:title ^(Open File)(.*)$"
    "float on, match:title ^(Open Folder)(.*)$"
    "size 640 480, match:title ^(Open Folder)(.*)$"
    "float on, match:title ^(Save As)(.*)$"
    "size 640 480, match:title ^(Save As)(.*)$"
    "float on, match:title ^(Library)(.*)$"
    "size 640 480, match:title ^(Library)(.*)$"
    "float on, match:title ^(Please choose a directory)(.*)$"
    "size 640 480, match:title ^(Please choose a directory)(.*)$"
  ];
}
