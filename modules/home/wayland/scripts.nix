{
  config,
  lib,
  pkgs,
  ...
}: let
  notification-time = "3000";

  wf-recorder = lib.getExe pkgs.wf-recorder;
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  ffmpeg = lib.getExe pkgs.ffmpeg;
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  slurp = lib.getExe pkgs.slurp;
  grim = lib.getExe pkgs.grim;
  swappy = lib.getExe pkgs.swappy;
in {
  # Make screen record and save it as mkv and gif
  record-area = pkgs.writeShellScriptBin "record-area" ''
    RECORD_PATH="$HOME/Videos/screenrecords"

    if ! pkill -x wf-recorder -SIGINT; then
      mkdir -p "$RECORD_PATH"
      path="$RECORD_PATH/record_$(date +%Y-%m-%d_%H-%M-%S)"

      ${notify-send} -t ${notification-time} "Screen recording" "Select an area to start the recording..."
      geometry="$(${slurp} -c '#${config.colorScheme.palette.base0F}' -w 2 -d -o || true)"

      if [ -z "$geometry" ]; then
        ${notify-send} -t ${notification-time} "Screen recording" "Cancelled"
        exit 0
      fi

      sleep 0.2
      ${wf-recorder} -g "$geometry" -f "$path.mkv"

      ${ffmpeg} -i "$path.mkv" -vf "fps=15,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$path.gif"
      ${notify-send} -t ${notification-time} "Screen recording" "Recording is ready: $path.{mkv,gif}"

      ${wl-copy} -t image/gif <"$path.gif"
      echo "file://$path.mkv" | ${wl-copy} -t text/uri-list
    fi &
  '';

  # Make a screenshot of the screen (including all monitors) and a selected area
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    mkdir -p "$HOME/Pictures/Screenshots"
    cd "$HOME/Pictures/Screenshots" || exit

    geometry="$(${slurp} -c '#ff3f3faf' -w 2 -d -o || true)"

    if [ -n "$geometry" ]; then
      ${grim} -g "$geometry" -t png area.png
    else
      ${grim} -t png area.png
    fi

    if [ -f area.png ]; then
      AREA_FILENAME=area_"$(date +%Y-%m-%d_%H-%M-%S)".png
      mv area.png "$AREA_FILENAME"
      ${swappy} -f "$AREA_FILENAME" -o "''${AREA_FILENAME%.png}-annotated.png"
    fi
  '';
}
