{pkgs, ...}: {
  xdg.desktopEntries = {
    coseda-tunnel = {
      name = "COSEDA Tunnel";
      exec = "coseda-tunnel";
      terminal = false;
      type = "Application";
      categories = ["Development"];
    };
    coside = {
      name = "COSIDE";
      exec = "coside";
      terminal = false;
      type = "Application";
      categories = ["Development"];
    };
    coside-sdk = {
      name = "COSIDE SDK";
      exec = "coside-sdk";
      terminal = false;
      type = "Application";
      categories = ["Development"];
    };
  };

  home.packages = [
    # COSIDE
    (pkgs.writeShellScriptBin "coside" ''
      exec bash-no-nix env COSIDE_SHELL_OPTIONS='-f -c gnome-terminal' GTK_THEME=Adwaita COSIDE_LICENSE_FILE=27000@192.168.178.88 "$HOME/Apps/coside/coside-latest/coside" "$@"
    '')

    # Eclipse COSIDE SDK
    (pkgs.writeShellScriptBin "coside-sdk" ''
      COSIDE_INSTALL_PATH="$HOME/Apps/coside/coside-latest"
      COSIDE_SDK_DIR="$HOME/Apps/eclipse/coside-sdk-latest"
      SOURCE_COMMAND="source $COSIDE_INSTALL_PATH/coside --setenv"
      EXEC_CMD="cd $COSIDE_INSTALL_PATH && $SOURCE_COMMAND && $COSIDE_SDK_DIR/coside-sdk/eclipse -data $COSIDE_SDK_DIR/ws"
      exec bash-no-nix env GTK_THEME=Adwaita tcsh -c "$EXEC_CMD"
    '')

    # Tunnel for work network
    (pkgs.writeShellScriptBin "coseda-tunnel" ''
      # Search for `--kill` argument
      while [ $# -ne 0 ]; do
        case "$1" in
        --kill)
          KILL=true
          ;;
        esac
        shift
      done

      TUNNEL_COMMAND='ssh -f -N'
      SSH_CONFIG="$HOME/.ssh/config"
      # Also take care of all included files in the ssh configuration
      INCLUDED_FILES=$(grep -E '^\s*Include\s+' "$SSH_CONFIG" | awk '{print $2}')

      # Find hosts that end with 'tunnel' in ssh configuration and all included files
      HOSTS=$(grep -E 'Host .*-tunnel$' "$SSH_CONFIG" "$INCLUDED_FILES" | awk '{print $2}')

      for HOST in $HOSTS; do
        # Get all already running tunnel processes
        PS=$(pgrep -u "$USER" -a "ssh" | grep "$TUNNEL_COMMAND $HOST$")
        PID=$(echo "$PS" | awk '{print $1}' | sed ':a;N;$!ba;s/\n/ /g')

        # Kill them all
        if [ -n "$PID" ]; then
          echo "Kill existing tunnel for $HOST (PID=$PID)"
          kill "$PID"
          sleep 1 # Graceful termination
          if ps -p "$PID"> /dev/null; then
            kill -9 "$PID"
          fi
        fi

        # (Re-)Create the tunnels if no explicitly `--kill` argument was given
        if [ -z "$KILL" ]; then
          echo "Create tunnel for $HOST"
          $TUNNEL_COMMAND "$HOST"
        fi
      done
    '')
  ];
}
