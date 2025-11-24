{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.opts.home.gui.enable {
    home.packages = with pkgs; [
      # MS Office alternatives
      onlyoffice-desktopeditors
      libreoffice

      # Image editing
      gimp

      # PDF Viewer
      kdePackages.okular

      # Note-taking apps
      (config.lib.nixGL.wrap obsidian)
    ];

    programs.zathura = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.zathura;
      options = {
        selection-notification = true;

        selection-clipboard = "clipboard";
        adjust-open = "best-fit";
        pages-per-row = "1";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        zoom-min = "10";

        notification-error-bg = "#f7768e";
        notification-error-fg = "#c0caf5";
        notification-warning-bg = "#e0af68";
        notification-warning-fg = "#414868";
        notification-bg = "#1a1b26";
        notification-fg = "#c0caf5";
        completion-bg = "#1a1b26";
        completion-fg = "#a9b1d6";
        completion-group-bg = "#1a1b26";
        completion-group-fg = "#a9b1d6";
        completion-highlight-bg = "#414868";
        completion-highlight-fg = "#c0caf5";
        index-bg = "#1a1b26";
        index-fg = "#c0caf5";
        index-active-bg = "#414868";
        index-active-fg = "#c0caf5";
        inputbar-bg = "#1a1b26";
        inputbar-fg = "#c0caf5";
        statusbar-bg = "#1a1b26";
        statusbar-fg = "#c0caf5";
        highlight-color = "#e0af68";
        highlight-active-color = "#9ece6a";
        default-bg = "#1a1b26";
        default-fg = "#c0caf5";
        render-loading = true;
        render-loading-fg = "#1a1b26";
        render-loading-bg = "#c0caf5";
        # Recolor mode settings
        # <C-r> to switch modes
        recolor-lightcolor = "#1a1b26";
        recolor-darkcolor = "#c0caf5";
        recolor = "true";
      };
    };
  };
}
