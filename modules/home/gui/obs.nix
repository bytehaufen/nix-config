{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.opts.home.gui.enable && config.opts.home.programs.obs.enable) {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      plugins = with pkgs.obs-studio-plugins; [
        # Screen capture
        wlrobs
        obs-vaapi
        obs-teleport
        obs-vkcapture
        obs-gstreamer
        obs-3d-effect
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        obs-shaderfilter
        obs-source-record
        obs-livesplit-one
        looking-glass-obs
        obs-vintage-filter
        obs-command-source
        obs-move-transition
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };
}
