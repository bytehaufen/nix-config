{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.tmux = {
      enable = true;

      # Fix cursor artifacts during synchronized redraws:
      # https://github.com/tmux/tmux/issues/5619
      # Use the regular package once nixpkgs provides tmux >= 3.8.
      package =
        if lib.versionOlder pkgs.tmux.version "3.8"
        then
          pkgs.tmux.overrideAttrs (_: {
            version = "3.8";
            src = pkgs.fetchurl {
              url = "https://github.com/tmux/tmux/releases/download/3.8/tmux-3.8.tar.gz";
              hash = "sha256-55xpnH6UnczQpKEl4XuNEmHjEbFpedvI6zRULzlm2C4=";
            };
          })
        else pkgs.tmux;

      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      customPaneNavigationAndResize = false; # That is the default

      escapeTime = 50;

      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      newSession = true;
      shell = lib.getExe pkgs.zsh;

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
        vim-tmux-navigator
      ];

      shortcut = "a";
      terminal = "tmux-256color";

      extraConfig = ''
        ################
        # Extra config #
        ################

        # Enable passthrough for images
        set -gq allow-passthrough on


        # Update files on focus (using for vim)
        set -s focus-events on

        # 256 colors support
        set -as terminal-features ',xterm-kitty:RGB:extkeys:sync:hyperlinks'

        # Set titles
        set-option -g set-titles on
        set-option -g set-titles-string '[#S:#I #T] #W'

        ######################
        # Keys configuration #
        ######################

        # Copy mode
        bind v copy-mode
        bind -T copy-mode-vi v send -X begin-selection
        unbind -T copy-mode-vi MouseDragEnd1Pane              # don't exit copy mode after dragging with mouse

        # Better copy / paste
        unbind p
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy && wl-paste -n | wl-copy -p'
        bind p run 'wl-paste -n | tmux load-buffer - ; tmux paste-buffer'

        # Pane navigation
        bind k selectp -U
        bind j selectp -D
        bind h selectp -L
        bind l selectp -R

        # Pane resizing
        bind H resize-pane -L 5
        bind J resize-pane -D 5
        bind K resize-pane -U 5
        bind L resize-pane -R 5

        bind R run-shell " \
          tmux source-file ~/.config/tmux/tmux.conf > /dev/null; \
          tmux display-message 'Sourced ~/.config/tmux/tmux.conf'"

        # Splitting
        bind '-' split-window -v -l 20% -c '#{pane_current_path}'
        bind '_' split-window -v -c '#{pane_current_path}'
        bind "\\" split-window -h -l 20% -c '#{pane_current_path}'
        bind '|' split-window -h -c '#{pane_current_path}'

        # Swap panes
        bind '>' swap-pane -D       # swap current pane with the next one
        bind '<' swap-pane -U       # swap current pane with the previous one

        # Session navigation
        bind -n M-, switch-client -p # previous session
        bind -n M-. switch-client -n # next session

        # window navigation
        bind -r C-h previous-window # select previous window
        bind -r C-l next-window     # select next window
        bind C-a last-window        # move to last active window

        # Maximize / restore pane
        bind -r m resize-pane -Z

        # Create window in current dir
        bind c new-window -c '#{pane_current_path}'

        # Bell notifications
        setw -g monitor-bell on
        set -g bell-action any
        set -g visual-bell off

        set -s extended-keys on
        set -s extended-keys-format csi-u

        ################################
        # Static Catppuccin palette #
        ################################

        # Keep the custom status layout, bell alerts, and clock formats.
        set -g mode-style "fg=#{@thm_blue},bg=#{@thm_surface_0}"

        set -g message-style "fg=#{@thm_blue},bg=#{@thm_surface_0}"
        set -g message-command-style "fg=#{@thm_blue},bg=#{@thm_surface_0}"

        set -g pane-border-style "fg=#{@thm_overlay_0}"
        set -g pane-active-border-style "fg=#{@thm_blue}"

        set -g status "on"
        set -g status-justify "left"

        set -g status-style "fg=#{@thm_fg},bg=#{@thm_bg}"

        set -g status-left-length "100"
        set -g status-right-length "100"

        set -g status-left-style NONE
        set -g status-right-style NONE

        # Current session + bell alerts from other sessions
        set -g status-left "#[fg=#{@thm_bg},bg=#{@thm_blue},bold] #S #[fg=#{@thm_blue},bg=#{@thm_bg},nobold,nounderscore,noitalics]#{S:#{?session_bell_flag,#[fg=#{@thm_red}]#[bg=#{@thm_bg}]#[fg=#{@thm_bg}]#[bg=#{@thm_red}]#[bold] ! #{session_name} #[fg=#{@thm_red}]#[bg=#{@thm_bg}]#[nobold],},}"

        set -g status-right "#[fg=#{@thm_bg},bg=#{@thm_bg},nobold,nounderscore,noitalics]#[fg=#{@thm_blue},bg=#{@thm_bg}] #{prefix_highlight} #[fg=#{@thm_surface_0},bg=#{@thm_bg},nobold,nounderscore,noitalics]#[fg=#{@thm_fg},bg=#{@thm_surface_0}] %Y-%m-%d  %I:%M %p #[fg=#{@thm_blue},bg=#{@thm_surface_0},nobold,nounderscore,noitalics]#[fg=#{@thm_bg},bg=#{@thm_blue},bold] #h "
        if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
          set -g status-right "#[fg=#{@thm_bg},bg=#{@thm_bg},nobold,nounderscore,noitalics]#[fg=#{@thm_blue},bg=#{@thm_bg}] #{prefix_highlight} #[fg=#{@thm_surface_0},bg=#{@thm_bg},nobold,nounderscore,noitalics]#[fg=#{@thm_fg},bg=#{@thm_surface_0}] %Y-%m-%d  %H:%M #[fg=#{@thm_blue},bg=#{@thm_surface_0},nobold,nounderscore,noitalics]#[fg=#{@thm_bg},bg=#{@thm_blue},bold] #h "
        }

        setw -g window-status-activity-style "underscore,fg=#{@thm_subtext_1},bg=#{@thm_bg}"
        setw -g window-status-bell-style "bold,fg=#{@thm_bg},bg=#{@thm_red}"
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#{@thm_subtext_1},bg=#{@thm_bg}"
        setw -g window-status-format "#[fg=#{@thm_bg},bg=#{@thm_bg},nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#{@thm_bg},bg=#{@thm_bg},nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=#{@thm_bg},bg=#{@thm_surface_0},nobold,nounderscore,noitalics]#[fg=#{@thm_blue},bg=#{@thm_surface_0},bold] #I  #W #F #[fg=#{@thm_surface_0},bg=#{@thm_bg},nobold,nounderscore,noitalics]"
      '';
    };
    catppuccin.tmux.extraConfig = ''
      set -g @catppuccin_window_current_number_color "#{@thm_blue}"
    '';
  };
}
