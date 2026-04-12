{
  lib,
  config,
  pkgs,
  ...
}: {
  config = with pkgs; {
    home.packages =
      [
        vulkan-tools
      ]
      ++ lib.optionals config.opts.home.programs.copilot.enable [
        # FIXME: Workaround for `#505644` remove when fixed upstream
        (pkgs.github-copilot-cli.overrideAttrs (_: {
          doInstallCheck = false;
        }))
      ]
      ++ lib.optionals config.opts.home.programs.ollama-vulkan.enable [
        ollama-vulkan
      ]
      ++ lib.optionals config.opts.home.programs.ollama-cuda.enable [
        stable.ollama-cuda
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
