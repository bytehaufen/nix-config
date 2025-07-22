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

        userName = vars.gitName;
        userEmail = vars.email;

        signing = {
          format = "ssh";
          key = config.age.secrets.id_ed25519_github.path;
          signByDefault = false; # NOTE: When signed, cannot do some rebase actions
        };

        extraConfig = {
          core = {
            editor = "nvim";
          };
          delta = {
            features = "side-by-side decorations";
            navigate = true;
            dark = true;
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

        # Git **delta**
        delta = {
          enable = true;
          options = {
            dark = true;
            show-syntax-themes = true;
            minus-style = "syntax '#37222c'";
            minus-non-emph-style = "syntax '#37222c'";
            minus-emph-style = "syntax '#713137'";
            minus-empty-line-marker-style = "syntax '#37222c'";
            line-numbers-minus-style = "#914c54";
            plus-style = "syntax '#20303b'";
            plus-non-emph-style = "syntax '#20303b'";
            plus-emph-style = "syntax '#2c5a66'";
            plus-empty-line-marker-style = "syntax '#20303b'";
            line-numbers-plus-style = "#449dab";
            line-numbers-zero-style = "#3b4261";
          };
        };
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
            theme = {
              activeBorderColor = [
                "#ff9e64"
                "bold"
              ];
              inactiveBorderColor = ["#27a1b9"];
              searchingActiveBorderColor = [
                "#ff9e64"
                "bold"
              ];
              optionsTextColor = ["#7aa2f7"];
              selectedLineBgColor = ["#283457"];
              cherryPickedCommitFgColor = ["#7aa2f7"];
              cherryPickedCommitBgColor = ["#bb9af7"];
              markedBaseCommitFgColor = ["#7aa2f7"];
              markedBaseCommitBgColor = ["#e0af68"];
              unstagedChangesColor = ["#db4b4b"];
              defaultFgColor = ["#c0caf5"];
            };
          };
          git = {
            paging = {
              colorArg = "always";
              pager = "delta --dark --paging=never -s";
            };
            parseEmoji = true;
          };
        };
      };
    };
  };
}
