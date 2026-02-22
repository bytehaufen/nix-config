{
  lib,
  config,
  pkgs,
  ...
}: {
  config = with pkgs; {
    home.packages =
      lib.optionals config.opts.home.programs.copilot.enable [
        github-copilot-cli
      ]
      ++ lib.optionals config.opts.home.programs.ollama-vulkan.enable [
        ollama-vulkan
      ]
      ++ lib.optionals config.opts.home.programs.ollama.enable [
        ollama
      ]
      ++ lib.optionals config.opts.home.programs.mcphost.enable [
        mcphost
      ]
      ++ lib.optionals config.opts.home.programs.openai-codex.enable [
        codex
      ];
  };
}
