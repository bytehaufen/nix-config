{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs.tmux = {
      enable = true;

      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      customPaneNavigationAndResize = false; # That is the default

      escapeTime = 1;

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
        set -g focus-events on

        set -g default-terminal "tmux-256color"

        # 256 colors support
        set-option -sa terminal-features ',xterm-kitty:RGB'

        # Set titles
        set-option -g set-titles on
        set-option -g set-titles-string '[#S:#I #T] #W'

        # Termux specific
        set-option -g focus-events on

        set-option -g status "on"

        ######################
        # Keys configuration #
        ######################

        # Copy mode
        bind-key v copy-mode
        unbind -T copy-mode-vi MouseDragEnd1Pane              # don't exit copy mode after dragging with mouse

        # Better copy / paste
        unbind p
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy && wl-paste -n | wl-copy -p'
        bind-key p run 'wl-paste -n | tmux load-buffer - ; tmux paste-buffer'

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

        bind-key R run-shell " \
          tmux source-file ~/.config/tmux/tmux.conf > /dev/null; \
          tmux display-message 'Sourced ~/.config/tmux/tmux.conf'"

        # Splitting
        bind-key '-' split-window -v -l 20% -c '#{pane_current_path}'
        bind-key '_' split-window -v -c '#{pane_current_path}'
        bind-key "\\" split-window -h -l 20% -c '#{pane_current_path}'
        bind-key '|' split-window -h -c '#{pane_current_path}'

        # Swap panes
        bind '>' swap-pane -D       # swap current pane with the next one
        bind '<' swap-pane -U       # swap current pane with the previous one

        # window navigation
        bind -r C-h previous-window # select previous window
        bind -r C-l next-window     # select next window
        bind Tab last-window        # move to last active window

        # Maximize / restore pane
        bind -r m resize-pane -Z

        # Create window in current dir
        bind c new-window -c '#{pane_current_path}'

        ##############################
        # TokyoNight colors for Tmux #
        ##############################

        set -g mode-style "fg=#7aa2f7,bg=#3b4261"

        set -g message-style "fg=#7aa2f7,bg=#3b4261"
        set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

        set -g pane-border-style "fg=#3b4261"
        set -g pane-active-border-style "fg=#7aa2f7"

        set -g status "on"
        set -g status-justify "left"

        set -g status-style "fg=#7aa2f7,bg=#16161e"

        set -g status-left-length "100"
        set -g status-right-length "100"

        set -g status-left-style NONE
        set -g status-right-style NONE

        set -g status-left "#[fg=#15161e,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#16161e,nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#16161e] #{prefix_highlight} #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161e,bg=#7aa2f7,bold] #h "
        if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
          set -g status-right "#[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#16161e] #{prefix_highlight} #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %H:%M #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161e,bg=#7aa2f7,bold] #h "
        }

        setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#16161e"
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#a9b1d6,bg=#16161e"
        setw -g window-status-format "#[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=#16161e,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics]"

        # tmux-plugins/tmux-prefix-highlight support
        set -g @prefix_highlight_output_prefix "#[fg=#e0af68]#[bg=#16161e]#[fg=#16161e]#[bg=#e0af68]"
        set -g @prefix_highlight_output_suffix ""
      '';
    };
  };
}
