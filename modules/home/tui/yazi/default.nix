{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    # General file info
    home.packages = [pkgs.exiftool];

    programs.yazi = {
      enable = true;

      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;

      settings = {
        mgr = {
          layout = [1 4 3];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "mtime";
          show_hidden = true;
          show_symlink = true;
        };

        preview = {
          tab_size = 2;
          max_width = 600;
          max_height = 900;
          cache_dir = config.xdg.cacheHome;
        };
      };
      plugins = {
        open-with = ./plugins/open-with;
      };

      keymap = {
        mgr.prepend_keymap = [
          # Open selected file/dir with a specific command
          {
            run = "plugin open-with";
            on = ["O"];
            desc = "Open with in terminal";
          }

          # Open selected file/dir with a specific command **blocked**
          {
            run = "plugin open-with --args=block";
            on = ["<C-o>"];
            desc = "Open with";
          }
        ];
      };
    };

    xdg.configFile."yazi/theme.toml".source = ./theme.toml;
  };
}
