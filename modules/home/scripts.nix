{pkgs, ...}: let
  bash-no-nix = pkgs.writeShellScriptBin "bash-no-nix" ''
    set -euo pipefail

    # Strip nix paths
    CLEAN_PATH=$(printf "%s" "$PATH" | tr ':' '\n' | grep -v '^/nix/store' | grep -v "$HOME/.nix-profile" | grep -v '/nix/var/nix/profiles/default/bin' | paste -sd:)
    export PATH="$CLEAN_PATH"

    unset NIX_PATH NIX_PROFILES NIX_SSL_CERT_FILE NIX_USER_PROFILE_DIR NIX_REMOTE NIX_BUILD_SHELL IN_NIX_SHELL NIX_BINTOOLS NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu NIX_BUILD_CORES NIX_CC NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu NIX_CFLAGS_COMPILE NIX_CONFIG NIX_ENFORCE_NO_NATIVE NIX_HARDENING_ENABLE NIX_LDFLAGS NIX_STORE

    if [ $# -gt 0 ]; then
      exec "$@"
    else
      exec /usr/bin/env bash --noprofile --norc
    fi
  '';
in {
  home.packages = [bash-no-nix];
}
