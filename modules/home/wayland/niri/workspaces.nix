{
  config,
  lib,
  ...
}: let
  cfg = config.opts.home.windowManager.niri;
  plan = import ./workspace-plan.nix;

  quote = builtins.toJSON;
  workspaceNames = lib.concatLists (builtins.attrValues plan.layout);

  renderWorkspace = name: "workspace ${quote name}";
  renderMatch = match:
    "    match"
    + lib.optionalString (match ? appId) " app-id=${quote match.appId}"
    + lib.optionalString (match ? title) " title=${quote match.title}";

  renderRule = rule: match:
    lib.concatStringsSep "\n" (
      [
        "window-rule {"
        (renderMatch match)
        "    open-on-workspace ${quote rule.workspace}"
      ]
      ++ lib.optional (match ? openFocused) "    open-focused ${quote match.openFocused}"
      ++ lib.optional (match ? openFloating) "    open-floating ${quote match.openFloating}"
      ++ ["}"]
    );
in {
  config = lib.mkIf (cfg.enable && cfg.monitorProfiles != {}) {
    assertions = [
      {
        assertion = builtins.length workspaceNames == builtins.length (lib.unique workspaceNames);
        message = "Niri named workspaces in workspace-plan.nix must be unique.";
      }
      {
        assertion = lib.all (rule: builtins.elem rule.workspace workspaceNames) plan.rules;
        message = "All Niri workspace rules must refer to a declared named workspace.";
      }
      {
        assertion = lib.all (rule: rule.matches != []) plan.rules;
        message = "Every Niri workspace rule must contain at least one match directive.";
      }
    ];

    opts.home.windowManager.niri.extraConfig = lib.mkAfter (
      lib.concatStringsSep "\n\n" [
        (lib.concatMapStringsSep "\n" renderWorkspace workspaceNames)
        (lib.concatMapStringsSep "\n\n"
          (rule: lib.concatMapStringsSep "\n\n" (renderRule rule) rule.matches)
          plan.rules)
      ]
    );
  };
}
