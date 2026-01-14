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
      "anyrun"
      "osd"
      "logout_dialog"
    ];

    blurred = lib.concatLists [
      lowopacity
      highopacity
    ];
  in [
    "blur true, match:namespace ${toRegex blurred}"
    "xray true 1, match:namespace ${toRegex ["bar"]}"
  ];

  # Window rules
  windowrule = [
    # Gnome calculator
    "match:class ^(org.gnome.Calculator)$, float true"

    # Quickgui (Quickemu)
    "match:class ^(quickgui)$, float true"
    "match:class ^(quickgui)$, move 100%-w-20"
    "match:class ^(spicy)$, float true"
    "match:class ^(spicy)$, size 800 600"

    # Allow tearing in games
    "match:class ^(osu\!|cs2)$, immediate true"

    # Make Firefox PiP window floating and sticky
    "match:title ^(Picture-in-Picture)$, float true"
    "match:title ^(Picture-in-Picture)$, pin true"

    # Throw sharing indicators away
    "match:title ^(Firefox — Sharing Indicator)$, workspace special silent"
    "match:title ^(.*is sharing (your screen|a window)\.)$, workspace special silent"

    # Idle inhibit while watching videos
    "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
    "match:class ^(brave-browser)$ match:title:^(.*YouTube.*)$, idle_inhibit focus"
    "match:class ^(brave-browser)$, idle_inhibit fullscreen"
    "match:class ^(firefox)$ match:title:^(.*YouTube.*)$, idle_inhibit focus"
    "match:class ^(firefox)$, idle_inhibit fullscreen"

    # Do not go idle while anything is fullscreen
    "match:class ^(kitty.*)$, idle_inhibit fullscreen"

    # Musicpod
    "match:class ^(musicpod)$, float true"
    "match:class ^(musicpod)$, size 500 700"
    "match:class ^(musicpod)$, monitor 0"
    "match:class ^(musicpod)$, move 100%-w-20"

    # Gpt4all
    "match:class ^(io.gpt4all.)$, float true"
    "match:class ^(io.gpt4all.)$, size 1280 720"
    "match:class ^(io.gpt4all.)$, move 100%-w-20"

    "match:class ^(gcr-prompter)$, dim_around true"
    "match:class ^(xdg-desktop-portal-gtk)$, dim_around true"
    "match:class ^(polkit-gnome-authentication-agent-1)$, dim_around true"

    # Fix xwayland apps
    "match:xwayland 1, rounding 0"
    "match:class ^(.*jetbrains.*)$ match:title:^(Confirm Exit|Open Project|win424|win201|splash)$, center true"
    "match:class ^(.*jetbrains.*)$ match:title:^(splash)$, size 640 400"

    # File / directory chooser
    "match:title ^(Open File)(.*)$, float true"
    "match:title ^(Open File)(.*)$, size 640 480"
    "match:title ^(Open Folder)(.*)$, float true"
    "match:title ^(Open Folder)(.*)$, size 640 480"
    "match:title ^(Save As)(.*)$, float true"
    "match:title ^(Save As)(.*)$, size 640 480"
    "match:title ^(Library)(.*)$, float true"
    "match:title ^(Library)(.*)$ , size 640 480"
    "match:title ^(Please choose a directory)(.*)$, float true"
    "match:title ^(Please choose a directory)(.*)$, size 640 480"
  ];
}
