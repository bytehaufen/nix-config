{
  layout = {
    m1 = [
      "m1w1"
      "m1w2"
      "m1w3"
    ];

    m2 = [
      "m2w1"
      "m2w2"
      "m2w3"
    ];

    m3 = [
      "m3w1"
      "m3w2"
      "m3w3"
    ];
  };

  rules = [
    # m1w1: Brave
    {
      workspace = "m1w1";
      matches = [
        {
          appId = "(?i)^brave-browser$";
        }
      ];
    }

    # m1w2: COSIDE runtime product
    {
      workspace = "m1w2";
      matches = [
        # Start screen
        {
          title = "^Eclipse$";
          appId = "^Java$";
          openFocused = false;
        }

        # Splash
        {
          title = "(?i)^coside$";
          appId = "^Java$";
          openFocused = false;
        }

        # COSIDE runtime product
        {
          title = "^runtime-coside[.]product - COSIDE®";
          appId = "^COSIDE®$";
          openFocused = false;
        }
      ];
    }

    # m1w3: COSIDE || Eclipse git staging
    {
      workspace = "m1w3";
      matches = [
        # Workspace selector
        {
          title = "^COSIDE® Launcher";
          appId = "^COSIDE®$";
          openFocused = false;
        }

        # COSIDE
        {
          title = "^coside_workspace";
          appId = "^COSIDE®$";
          openFocused = false;
        }

        # Eclipse Git Staging window
        {
          title = "^$";
          appId = "^Eclipse$";
          openFocused = false;
        }
      ];
    }

    # m2w1: Kitty
    {
      workspace = "m2w1";
      matches = [
        {
          appId = "(?i)^kitty$";
          openFocused = true;
        }
      ];
    }

    # m2w2: Eclipse COSIDE SDK
    {
      workspace = "m2w2";
      matches = [
        # Eclipse SDK splash
        {
          title = "^Eclipse$";
          appId = "^java$";
          openFocused = false;
        }

        # Eclipse COSIDE SDK
        {
          title = "^ws - ";
          appId = "^Eclipse$";
          openFocused = false;
        }
      ];
    }

    # m3w1: Teams for Linux
    {
      workspace = "m3w1";
      matches = [
        {
          appId = "(?i)^teams-for-linux$";
          openFocused = false;
        }
      ];
    }
  ];
}
