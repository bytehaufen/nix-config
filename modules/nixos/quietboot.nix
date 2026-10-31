{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.nixos.quietboot.enable {
    console = {
      useXkbConfig = true;
      earlySetup = false;
    };

    boot = {
      # Graphical boot animation
      plymouth = {
        enable = true;
        ## TODO: Style this
        # theme = "spinner-monochrome";
        # themePackages = [
        #    # By default we would install all themes
        #   (adi1090x-plymouth-themes.override {
        #     selected_themes = [ "rings" ];
        #   })
        #   (pkgs.plymouth-spinner-monochrome.override {inherit (config.boot.plymouth) logo;})
        # ];
      };
      # Hide OS choice of bootloader
      loader.timeout = 0;
      # Silent boot
      kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];
      consoleLogLevel = 0;
    };
  };
}
