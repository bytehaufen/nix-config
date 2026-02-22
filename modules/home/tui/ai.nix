{
  lib,
  config,
  pkgs,
  ...
}: {
  config = with pkgs; {
    home.packages =
      [
        (config.lib.nixGL.wrap vulkan-tools)
      ]
      ++ lib.optionals config.opts.home.programs.copilot.enable [
        (config.lib.nixGL.wrap github-copilot-cli)
      ]
      ++ lib.optionals config.opts.home.programs.ollama-vulkan.enable [
        (config.lib.nixGL.wrap ollama-vulkan)
      ]
      ++ lib.optionals config.opts.home.programs.ollama.enable [
        (config.lib.nixGL.wrap ollama)
      ]
      ++ lib.optionals config.opts.home.programs.mcphost.enable [
        (config.lib.nixGL.wrap mcphost)
      ]
      ++ lib.optionals config.opts.home.programs.openai-codex.enable [
        (config.lib.nixGL.wrap codex)
      ];
  };
}
