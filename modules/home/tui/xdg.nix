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
        defaultApplications = let
          browser = ["brave-browser.desktop" "firefox.desktop"];
          editor = ["nvim.desktop"];
          explorer = ["org.gnome.Nautilus.desktop" "yazi.desktop"];
          imageViewer = ["imv-dir.desktop"];
          mail = ["userapp-Thunderbird-IGOQ71.desktop"];
          onlyoffice = ["onlyoffice-desktopeditors.desktop"];
          videoViewer = ["mpv.desktop"];
          zathura = ["org.pwmt.zathura.desktop"];
        in {
          "application/epub+zip" = zathura;
          "application/msword" = onlyoffice;
          "application/pdf" = zathura;
          "application/vnd.ms-excel" = onlyoffice;
          "application/vnd.ms-powerpoint" = onlyoffice;
          "application/vnd.ms-word.document.macroenabled.12" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = onlyoffice;
          "application/xhtml+xml" = browser;
          "application/xml" = browser;
          "image/*" = imageViewer;
          "image/gif" = imageViewer;
          "image/jpeg" = imageViewer;
          "image/png" = imageViewer;
          "image/webp" = imageViewer;
          "inode/directory" = explorer;
          "message/rfc822" = mail;
          "text/csv" = editor;
          "text/html" = browser;
          "text/plain" = editor;
          "text/tab-separated-values" = editor;
          "text/x-c" = editor;
          "text/x-diff" = editor;
          "text/x-shellscript" = editor;
          "video/*" = videoViewer;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/mailto" = mail;
          "x-scheme-handler/mid" = mail;
          "x-scheme-handler/unknown" = browser;
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
