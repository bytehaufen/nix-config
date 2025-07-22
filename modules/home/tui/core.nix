{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf config.opts.home.tui.enable {
    programs = {
      # Type `<ctrl> + r` to fuzzy search your shell history
      jq.enable = true;

      eza = {
        enable = true;
        enableNushellIntegration = false;
        git = true;
        icons = "auto";
      };

      # A command-line fuzzy finder
      fzf = {
        enable = true;
        colors = {
          "bg+" = "#283457";
          "bg" = "#16161e";
          "border" = "#27a1b9";
          "fg" = "#c0caf5";
          "gutter" = "#16161e";
          "header" = "#ff9e64";
          "hl+" = "#2ac3de";
          "hl" = "#2ac3de";
          "info" = "#545c7e";
          "marker" = "#ff007c";
          "pointer" = "#ff007c";
          "prompt" = "#2ac3de";
          "query" = "#c0caf5:regular";
          "scrollbar" = "#27a1b9";
          "separator" = "#ff9e64";
          "spinner" = "#ff007c";
        };
      };
    };

    home.packages = with pkgs; [
      # Archives
      unrar
      unzip
      zip

      # General
      libcap # POSIX capabilities

      # Notification
      libnotify

      # Utils
      detox # Harmonize file names
      duf # `df` replacement
      dust # `du` replacement
      e2fsprogs # Ext2/3/4 file system utilities
      exiftool # Metadata
      eza # `ls` replacement
      fd # `find` replacement
      file # File type detection
      poppler-utils # PDF utilities
      hexyl # Hex viewer
      hyperfine # Benchmarking
      lazydocker # Docker manager
      parted # Partitioning tool
      sd # Fast sed
      tealdeer # tldr

      # Image
      chafa # Character art facsimile generator
      ghostscript # PDF manipulation
      imagemagick # Image manipulation
      inkscape # Vector graphics editor
      ueberzugpp # Image viewer
      viu # Image viewer
    ];
  };
}
