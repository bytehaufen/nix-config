{
  vars,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    # Enable scrolling in git diff
    home.sessionVariables.DELTA_PAGER = "less -R";

    programs = {
      git = {
        enable = true;

        signing = {
          format = "ssh";
          key = config.age.secrets.id_ed25519_github.path;
          signByDefault = false; # NOTE: When signed, cannot do some rebase actions
        };

        settings = {
          user = {
            name = vars.gitName;
            inherit (vars) email;
          };

          core = {
            editor = "nvim";
          };

          delta = {
            navigate = true;
          };

          "delta \"interactive\"" = {
            keep-plus-minus-markers = false;
          };

          alias = {
            tree = "log --oneline --graph --decorate --all";
          };

          pull = {
            ff = "only";
          };

          diff = {
            colorMoved = "default";
            tool = "nvimdiff";
            guitool = "nvimdiff";
          };

          difftool = {
            prompt = false;
          };

          "difftool \"nvimdiff\"" = {
            cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
          };

          merge = {
            tool = "nvimmerge";
            conflictstyle = "zdiff3";
          };

          mergetool = {
            keepBackup = false;
            prompt = false;
          };

          "mergetool \"nvimmerge\"" = {
            cmd = "nvim -d \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\" -c '$wincmd w' -c 'wincmd J'";
          };

          color = {
            ui = "auto";
          };
          init = {
            defaultBranch = "main";
          };
          credential = {
            helper = "store";
          };
          ssh = {
            postBuffer = 524288000;
          };
          http = {
            postBuffer = 524288000;
          };
        };

        ignores = ["*~" "*.swp" "*result*" ".direnv" "node_modules"];
      };

      # Git **delta**
      delta = {
        enable = true;
        enableGitIntegration = true;
        # Keep Catppuccin and the existing side-by-side/decorations features together.
        options.features = lib.mkForce "catppuccin-${config.catppuccin.flavor} side-by-side decorations";
      };

      # Github-cli
      gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          prefer_editor_prompt = "disabled";
          aliases = {
            co = "pr checkout";
          };
        };
      };

      # Lazygit
      lazygit = {
        enable = true;
        settings = {
          gui = {
            nerdFontsVersion = "3";
          };
          git = {
            diffRenderers = [
              {
                colorArg = "always";
                command = "delta --paging=never -s";
              }
            ];
            parseEmoji = true;
          };
        };
      };
    };
  };
}
