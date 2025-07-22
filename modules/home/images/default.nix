{
  lib,
  config,
  ...
}: {
  # Make my images available under $XDG_CONFIG_HOME/images, so that they can be
  # set manually in applications
  config = lib.mkIf config.opts.home.gui.enable {
    xdg.configFile = {
      "images/avatar.jpg".source = ./avatar.jpg;
      "images/hyprland.png".source = ./hyprland.png;
    };
  };
}
