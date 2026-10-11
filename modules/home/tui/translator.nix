{
  pkgs,
  lib,
  config,
  ...
}: let
  translatorEnabled = config.opts.home.programs.translator.enable;
in {
  config = lib.mkIf translatorEnabled {
    home.packages = with pkgs.stable; [
      translatelocally

      translatelocally-models.de-en-base
      translatelocally-models.en-de-base
    ];

    programs.zsh.initContent =
      lib.mkIf config.programs.zsh.enable
      # bash
      ''
        en() {
          local text="$*"

          echo "de: $(printf '%s\n' "$text" | translateLocally -m en-de-base)"
        }

        de() {
          local text="$*"

          echo "en: $(printf '%s\n' "$text" | translateLocally -m de-en-base)"
        }
      '';
  };
}
