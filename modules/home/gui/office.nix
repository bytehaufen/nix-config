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
      pkgs.stable.libreoffice

      # Image editing
      gimp

      # PDF Viewer
      kdePackages.okular
    ];

    programs.zathura = {
      enable = true;
      package = pkgs.zathura;
      options = {
        selection-notification = true;

        selection-clipboard = "clipboard";
        adjust-open = "best-fit";
        pages-per-row = "1";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        zoom-min = "10";

        render-loading = true;
        recolor = "true";
      };
    };
  };
}
