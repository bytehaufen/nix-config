{...}: {
  imports = [
    ./core.nix
    ./work
  ];

  opts.home = {
    tui.enable = true;
    gui.enable = true;
    agenix.enable = true;
    nixGL.enable = true;
    windowManager.hyprland.enable = false;

    programs = {
      copilot.enable = true;
      ollama-vulkan.enable = true;
      mcphost.enable = true;
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
}
