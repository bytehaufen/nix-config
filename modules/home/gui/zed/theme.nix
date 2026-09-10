{
  lib,
  palette,
}: let
  c = name: "#${palette.${name}}";
  syntax = color: {inherit color;};
in {
  "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
  name = "Nix Colors";
  author = "Rico";
  themes = [
    {
      name = "Nix Colors (Dark)";
      appearance = "dark";
      style = {
        "background" = c "base00";
        "surface.background" = c "base01";
        "elevated_surface.background" = c "base01";
        "border" = c "base02";
        "border.variant" = c "base02";
        "border.focused" = c "base0D";
        "border.selected" = c "base0D";
        "text" = c "base05";
        "text.muted" = c "base04";
        "text.placeholder" = c "base04";
        "text.disabled" = c "base03";
        "text.accent" = c "base0D";
        "icon" = c "base05";
        "icon.muted" = c "base04";
        "icon.disabled" = c "base03";
        "icon.accent" = c "base0D";
        "element.background" = c "base01";
        "element.hover" = c "base02";
        "element.active" = c "base02";
        "element.selected" = c "base02";
        "ghost_element.hover" = c "base02";
        "ghost_element.active" = c "base02";
        "ghost_element.selected" = c "base02";
        "status_bar.background" = c "base01";
        "title_bar.background" = c "base01";
        "title_bar.inactive_background" = c "base01";
        "toolbar.background" = c "base00";
        "tab_bar.background" = c "base01";
        "tab.inactive_background" = c "base01";
        "tab.active_background" = c "base00";
        "panel.background" = c "base01";
        "panel.focused_border" = c "base0D";
        "pane.focused_border" = c "base0D";
        "pane_group.border" = c "base02";
        "editor.background" = c "base00";
        "editor.foreground" = c "base05";
        "editor.gutter.background" = c "base00";
        "editor.subheader.background" = c "base01";
        "editor.active_line.background" = "${c "base02"}80";
        "editor.highlighted_line.background" = c "base02";
        "editor.line_number" = c "base03";
        "editor.active_line_number" = c "base0D";
        "editor.invisible" = c "base03";
        "editor.wrap_guide" = c "base02";
        "editor.active_wrap_guide" = c "base03";
        "editor.document_highlight.read_background" = "${c "base0D"}26";
        "editor.document_highlight.write_background" = "${c "base0E"}26";
        "search.match_background" = "${c "base0A"}40";
        "scrollbar.thumb.background" = "${c "base04"}60";
        "scrollbar.thumb.hover_background" = "${c "base04"}90";
        "scrollbar.track.background" = "#00000000";
        "scrollbar.track.border" = c "base02";
        # Tokyo Night's Base16 palette puts red in base0F, not base08.
        "error" = c "base0F";
        "error.background" = "${c "base0F"}20";
        "error.border" = c "base0F";
        "warning" = c "base0A";
        "warning.background" = "${c "base0A"}20";
        "warning.border" = c "base0A";
        "info" = c "base0D";
        "hint" = c "base04";
        "success" = c "base0B";
        "created" = c "base0B";
        "modified" = c "base0E";
        "deleted" = c "base0F";
        "conflict" = c "base0A";
        "ignored" = c "base04";
        "terminal.background" = c "base00";
        "terminal.foreground" = c "base05";
        "terminal.bright_foreground" = c "base07";
        "terminal.dim_foreground" = c "base04";
        "terminal.ansi.black" = c "base01";
        "terminal.ansi.red" = c "base0F";
        "terminal.ansi.green" = c "base0B";
        "terminal.ansi.yellow" = c "base0A";
        "terminal.ansi.blue" = c "base0D";
        "terminal.ansi.magenta" = c "base0E";
        "terminal.ansi.cyan" = c "base0C";
        "terminal.ansi.white" = c "base05";
        "terminal.ansi.bright_black" = c "base03";
        "terminal.ansi.bright_red" = c "base0F";
        "terminal.ansi.bright_green" = c "base0B";
        "terminal.ansi.bright_yellow" = c "base0A";
        "terminal.ansi.bright_blue" = c "base0D";
        "terminal.ansi.bright_magenta" = c "base0E";
        "terminal.ansi.bright_cyan" = c "base0C";
        "terminal.ansi.bright_white" = c "base07";
        players = map (color: {
          cursor = color;
          background = color;
          selection = "${color}40";
        }) (map c ["base0D" "base0E" "base0B" "base0C" "base0F" "base0A"]);
        syntax =
          lib.mapAttrs (_: color: syntax (c color)) {
            attribute = "base09";
            boolean = "base09";
            comment = "base04";
            "comment.doc" = "base04";
            constant = "base09";
            constructor = "base0A";
            embedded = "base0F";
            emphasis = "base0E";
            "emphasis.strong" = "base0A";
            enum = "base0A";
            function = "base0D";
            hint = "base04";
            keyword = "base0E";
            label = "base0D";
            link_text = "base08";
            link_uri = "base09";
            number = "base09";
            operator = "base05";
            predictive = "base03";
            preproc = "base0E";
            primary = "base05";
            property = "base08";
            punctuation = "base05";
            "punctuation.bracket" = "base05";
            "punctuation.delimiter" = "base05";
            "punctuation.list_marker" = "base08";
            "punctuation.special" = "base0F";
            string = "base0B";
            "string.escape" = "base0C";
            "string.regex" = "base0C";
            "string.special" = "base0C";
            "string.special.symbol" = "base09";
            tag = "base08";
            "text.literal" = "base0B";
            title = "base0D";
            type = "base0A";
            variable = "base08";
            "variable.special" = "base0F";
          }
          // {
            emphasis = (syntax (c "base0E")) // {font_style = "italic";};
            "emphasis.strong" = (syntax (c "base0A")) // {font_weight = 700;};
          };
      };
    }
  ];
}
