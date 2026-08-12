{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.opts.home.windowManager.niri;
  plan = import ./workspace-plan.nix;

  inherit (lib) mkIf mkOption types;

  logicalOutputOrder = builtins.attrNames plan.layout;

  outputType = types.submodule {
    options = {
      criteria = mkOption {
        type = types.str;
        description = "Connector or manufacturer/model/serial output identifier.";
      };

      status = mkOption {
        type = types.enum [
          "enable"
          "disable"
        ];
        default = "enable";
        description = "Whether Kanshi should enable or disable this output.";
      };

      mode = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Kanshi output mode, for example 2560x1440@144Hz.";
      };

      position = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Kanshi logical output position as x,y.";
      };

      scale = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Kanshi output scale.";
      };

      transform = mkOption {
        type = types.nullOr (types.enum [
          "normal"
          "90"
          "180"
          "270"
          "flipped"
          "flipped-90"
          "flipped-180"
          "flipped-270"
        ]);
        default = null;
        description = "Kanshi output transform.";
      };

      adaptiveSync = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether Kanshi should enable adaptive sync.";
      };

      focus = mkOption {
        type = types.bool;
        default = false;
        description = "Focus this output after applying the profile and arranging workspaces.";
      };
    };
  };

  enabledLogicalOutputs = outputs:
    lib.filter
    (logicalOutput:
      builtins.hasAttr logicalOutput outputs
      && outputs.${logicalOutput}.status == "enable")
    logicalOutputOrder;

  workspaceAssignments = outputs: let
    enabled = enabledLogicalOutputs outputs;
  in
    if enabled == []
    then []
    else let
      fallback = builtins.head enabled;
    in
      builtins.concatLists (
        map
        (logicalOutput:
          map
          (workspace: {
            inherit workspace;
            target =
              if builtins.elem logicalOutput enabled
              then logicalOutput
              else fallback;
          })
          plan.layout.${logicalOutput})
        logicalOutputOrder
      );

  renderMoveCommands = outputs:
    lib.concatMapStringsSep "\n"
    (assignment: ''
      run_niri move-workspace-to-monitor ${lib.escapeShellArg outputs.${assignment.target}.criteria} --reference ${lib.escapeShellArg assignment.workspace}
    '')
    (workspaceAssignments outputs);

  renderIndexCommands = outputs: let
    assignments = workspaceAssignments outputs;
    targets = lib.unique (map (assignment: assignment.target) assignments);
  in
    lib.concatMapStringsSep "\n"
    (target: let
      workspaces =
        map
        (assignment: assignment.workspace)
        (lib.filter (assignment: assignment.target == target) assignments);
    in
      lib.concatStringsSep "\n" (
        builtins.genList
        (index: ''
          run_niri move-workspace-to-index ${toString (index + 1)} --reference ${lib.escapeShellArg (builtins.elemAt workspaces index)}
        '')
        (builtins.length workspaces)
      ))
    targets;

  renderFocusCommand = outputs: let
    focused =
      lib.filter
      (logicalOutput:
        outputs.${logicalOutput}.focus
        && outputs.${logicalOutput}.status == "enable")
      (builtins.attrNames outputs);
  in
    lib.optionalString (focused != []) ''
      run_niri focus-monitor ${lib.escapeShellArg outputs.${builtins.head focused}.criteria}
    '';

  workspaceScript = profileName: outputs:
    pkgs.writeShellApplication {
      name = "niri-arrange-workspaces-${profileName}";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.niri
      ];
      text = ''
        set -euo pipefail

        run_niri() {
          local attempt=1

          until niri msg action "$@"; do
            if [ "$attempt" -ge 50 ]; then
              printf 'Niri action failed after %s attempts: %s\n' "$attempt" "$*" >&2
              return 1
            fi

            attempt=$((attempt + 1))
            sleep 0.1
          done
        }

        ${renderMoveCommands outputs}

        ${renderIndexCommands outputs}

        ${renderFocusCommand outputs}
      '';
    };

  toKanshiOutput = output: builtins.removeAttrs output ["focus"];

  profiles =
    lib.mapAttrsToList
    (name: outputs: {inherit name outputs;})
    cfg.monitorProfiles;

  # Kanshi profiles describe complete connected-output sets. Sorting larger
  # profiles first also keeps the generated configuration intuitive.
  profilesBySpecificity =
    lib.sort
    (left: right:
      builtins.length (builtins.attrNames left.outputs)
      > builtins.length (builtins.attrNames right.outputs))
    profiles;

  toKanshiProfile = profile: let
    script = workspaceScript profile.name profile.outputs;
  in {
    profile = {
      inherit (profile) name;
      outputs =
        map
        (logicalOutput: toKanshiOutput profile.outputs.${logicalOutput})
        (builtins.attrNames profile.outputs);
      exec = [
        (lib.getExe script)
      ];
    };
  };
in {
  options.opts.home.windowManager.niri.monitorProfiles = mkOption {
    type = types.attrsOf (types.attrsOf outputType);
    default = {};
    description = ''
      Kanshi profiles keyed by profile name and then by logical output name.
      Logical outputs m1, m2, and m3 are connected to the shared Niri workspace plan.
    '';
  };

  config = mkIf (cfg.enable && cfg.monitorProfiles != {}) {
    assertions =
      lib.mapAttrsToList
      (profileName: outputs: {
        assertion = outputs != {};
        message = "Niri monitor profile ${profileName} must contain at least one output.";
      })
      cfg.monitorProfiles
      ++ lib.mapAttrsToList
      (profileName: outputs: {
        assertion = lib.any (logicalOutput: outputs.${logicalOutput}.status == "enable") (builtins.attrNames outputs);
        message = "Niri monitor profile ${profileName} must enable at least one output.";
      })
      cfg.monitorProfiles
      ++ lib.mapAttrsToList
      (profileName: outputs: let
        unknownLogicalOutputs =
          lib.filter
          (logicalOutput: !builtins.hasAttr logicalOutput plan.layout)
          (builtins.attrNames outputs);
      in {
        assertion = unknownLogicalOutputs == [];
        message =
          "Niri monitor profile ${profileName} contains unknown logical outputs: "
          + lib.concatStringsSep ", " unknownLogicalOutputs;
      })
      cfg.monitorProfiles
      ++ lib.mapAttrsToList
      (profileName: outputs: let
        focused =
          lib.filter
          (logicalOutput: outputs.${logicalOutput}.focus)
          (builtins.attrNames outputs);
      in {
        assertion =
          builtins.length focused
          <= 1
          && lib.all (logicalOutput: outputs.${logicalOutput}.status == "enable") focused;
        message = "Niri monitor profile ${profileName} can focus at most one output, and it must be enabled.";
      })
      cfg.monitorProfiles
      ++ lib.mapAttrsToList
      (profileName: outputs: let
        criteria = map (logicalOutput: outputs.${logicalOutput}.criteria) (builtins.attrNames outputs);
      in {
        assertion = builtins.length criteria == builtins.length (lib.unique criteria);
        message = "Niri monitor profile ${profileName} assigns the same physical output more than once.";
      })
      cfg.monitorProfiles;

    services.kanshi = {
      enable = true;
      settings = map toKanshiProfile profilesBySpecificity;
    };
  };
}
