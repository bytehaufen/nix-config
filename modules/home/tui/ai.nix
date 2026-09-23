{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  ollamaEnabled =
    config.opts.home.programs.ollama.enable
    || config.opts.home.programs.ollama-vulkan.enable
    || config.opts.home.programs.ollama-cuda.enable;

  llma-pkgs = inputs.llm-agents.packages.${pkgs.system};
in {
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
      ++ lib.optionals config.opts.home.programs.llama-cpp-cuda.enable [
        (llama-cpp.override {
          cudaSupport = true;
        })
      ]
      ++ lib.optionals config.opts.home.programs.ollama-vulkan.enable [
        ollama-vulkan
      ]
      ++ lib.optionals config.opts.home.programs.ollama-cuda.enable [
        ollama-cuda
      ]
      ++ lib.optionals config.opts.home.programs.ollama.enable [
        ollama
      ]
      ++ lib.optionals config.opts.home.programs.openai-codex.enable [
        llma-pkgs.codex-acp
        llma-pkgs.codex
      ]
      ++ lib.optionals config.opts.home.programs.omp.enable [
        llma-pkgs.omp
      ];

    xdg.desktopEntries = lib.mkIf config.opts.home.programs.openai-codex.enable {
      chatgpt = {
        name = "ChatGPT";
        exec = "brave --app=https://chatgpt.com";
        terminal = false;
        categories = ["Network"];
      };
    };

    home.file.".omp/agent/config.yml" = lib.mkIf config.opts.home.programs.omp.enable {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home/tui/omp/config.yml";
    };

    programs.zsh.shellAliases = lib.mkIf ollamaEnabled {
      ollama-64k = "OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=65536 ollama serve";
      ollama-128k = "OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=131072 ollama serve";
      ollama-256k = "OLLAMA_FLASH_ATTENTION=1 OLLAMA_KV_CACHE_TYPE=q8_0 OLLAMA_CONTEXT_LENGTH=262144 ollama serve";
    };
  };
}
