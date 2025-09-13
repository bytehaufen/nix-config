{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  anyrunPackage = inputs.anyrun.packages.${pkgs.system};
in {
  config = lib.mkIf config.opts.home.windowManager.hyprland.enable {
    programs.anyrun = {
      enable = true;

      package = anyrunPackage.anyrun;

      config = {
        plugins = with anyrunPackage; [
          applications
          dictionary
          randr
          rink
          shell
          symbols
          translate
        ];

        closeOnClick = true;
        width.fraction = 0.4;
        x.fraction = 0.5;
        y.absolute = 15;
        hidePluginInfo = false;
      };

      extraConfigFiles = {
        "applications.ron".text =
          # ron
          ''
            Config(
              desktop_actions: false,
              max_entries: 5,
              terminal: Some("kitty"),
            )
          '';

        "randr.ron".text =
          # ron
          ''
            Config(
              prefix: ":dp",
              max_entries: 10,
            )
          '';

        "shell.ron".text =
          # ron
          ''
            Config(
              prefix: ":!",
            )
          '';
      };

      extraCss =
        # css
        ''
          * {
            transition: 200ms ease;
            font-size: 1.3rem;
          }

          window {
            background: transparent;
          }

          box.main {
            padding: 5px;
            margin: 10px;
            border-radius: 10px;
            border: 2px solid @theme_selected_bg_color;
            background-color: @theme_bg_color;
            box-shadow: 0 0 5px black;
          }


          text {
            min-height: 30px;
            padding: 5px;
            border-radius: 5px;
          }

          .matches {
            background-color: rgba(0, 0, 0, 0);
            border-radius: 10px;
          }

          box.plugin:first-child {
            margin-top: 5px;
          }

          box.plugin.info {
            min-width: 200px;
          }

          list.plugin {
            background-color: rgba(0, 0, 0, 0);
          }

          label.match.description {
            font-size: 10px;
          }

          label.plugin.info {
            font-size: 14px;
          }

          .match {
            background: transparent;
          }

          .match:selected {
            border-left: 4px solid @theme_selected_bg_color;
            background: transparent;
            animation: fade 0.1s linear;
          }

          @keyframes fade {
            0% {
              opacity: 0;
            }

            100% {
              opacity: 1;
            }
          }
        '';
    };
  };
}
