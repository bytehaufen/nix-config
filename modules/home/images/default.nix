{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.gui.enable {
    home.file = {
      "Pictures/Avatars/mihouse.jpg".source = ./Avatars/milhouse.jpg;
      "Pictures/Avatars/bytehaufen.png".source = ./Avatars/bytehaufen.png;
      "Pictures/Wallpapers/dark-music.jpg".source = ./Wallpapers/dark-music.jpg;
    };
  };
}
