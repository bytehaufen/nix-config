{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      mime.enable = true;

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/epub+zip" = ["org.pwmt.zathura.desktop"];
          "application/msword" = ["onlyoffice-desktopeditors.desktop"];
          "application/pdf" = ["org.pwmt.zathura.desktop"];
          "application/vnd.ms-excel" = ["onlyoffice-desktopeditors.desktop"];
          "application/vnd.ms-powerpoint" = ["onlyoffice-desktopeditors.desktop"];
          "application/vnd.ms-word.document.macroenabled.12" = ["onlyoffice-desktopeditors.desktop"];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = ["onlyoffice-desktopeditors.desktop"];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = ["onlyoffice-desktopeditors.desktop"];
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["onlyoffice-desktopeditors.desktop"];
          "application/xhtml+xml" = ["brave-browser.desktop"];
          "application/xml" = ["brave-browser.desktop"];
          "image/gif" = ["vimiv.desktop"];
          "image/jpeg" = ["vimiv.desktop"];
          "image/png" = ["vimiv.desktop"];
          "image/svg+xml" = ["vimiv.desktop"];
          "image/webp" = ["vimiv.desktop"];
          "inode/directory" = ["xplr.desktop"];
          "message/rfc822" = ["userapp-Thunderbird-IGOQ71.desktop"];
          "text/csv" = ["nvim.desktop"];
          "text/html" = ["brave-browser.desktop"];
          "text/plain" = ["nvim.desktop"];
          "text/tab-separated-values" = ["visidata.desktop"];
          "text/x-c" = ["nvim.desktop"];
          "text/x-diff" = ["nvim.desktop"];
          "text/x-shellscript" = ["nvim.desktop"];
          "video/mp4" = ["mpv.desktop"];
          "video/x-matroska" = ["mpv.desktop"];
          "x-scheme-handler/about" = ["brave-browser.desktop"];
          "x-scheme-handler/http" = ["brave-browser.desktop"];
          "x-scheme-handler/https" = ["brave-browser.desktop"];
          "x-scheme-handler/mailto" = ["userapp-Thunderbird-IGOQ71.desktop"];
          "x-scheme-handler/mid" = ["userapp-Thunderbird-IGOQ71.desktop"];
          "x-scheme-handler/unknown" = ["brave-browser.desktop"];
        };
      };

      systemDirs.data = [
        "/usr/local/share"
        "/usr/share"
        "${config.home.homeDirectory}/.local/share"
        "${config.home.homeDirectory}/.nix-profile/share/applications"
        "${config.home.homeDirectory}/.nix-profile/share/"
      ];
    };
  };
}
