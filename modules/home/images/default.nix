{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.gui.enable {
    home.file = let
      link = config.lib.file.mkOutOfStoreSymlink;
    in {
      "Pictures/Avatars/mihouse.jpg".source = link ./Avatars/milhouse.jpg;
      "Pictures/Avatars/bytehaufen.png".source = link ./Avatars/bytehaufen.png;
      "Pictures/Wallpapers/dark-music.jpg".source = link ./Wallpapers/dark-music.jpg;
    };
  };
}
