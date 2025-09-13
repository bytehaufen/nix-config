{
  pkgs,
  config,
  lib,
  ...
}: let
  configPath = "${config.home.homeDirectory}/nix-config/modules/home/tui/neovim";
  vrapperPath = "${config.xdg.configHome}/vrapper";
  # Hacky to run under non-NixOS
  cheatsheet = pkgs.writeShellScript "vrapper-cheatsheet" ''
    zsh -c "source /home/rico/.config/zsh/.zshrc && kitty zsh -c \"cd /home/rico/.config/vrapper && python3 gen-cheatsheet.py && ${lib.getExe pkgs.glow} -p /tmp/cheatsheet.md\""
  '';
in {
  # For eclipses vim plugin
  home.file.".vrapperrc".text =
    # vim
    ''
      source ${vrapperPath}/files.vim
      source ${vrapperPath}/buffers.vim
      source ${vrapperPath}/code.vim
      source ${vrapperPath}/debug.vim
      source ${vrapperPath}/editor.vim
      source ${vrapperPath}/git.vim
      source ${vrapperPath}/goto.vim
      source ${vrapperPath}/help.vim
      source ${vrapperPath}/insertion.vim
      source ${vrapperPath}/java.vim
      source ${vrapperPath}/quit.vim
      source ${vrapperPath}/refactoring.vim
      source ${vrapperPath}/search.vim
      source ${vrapperPath}/settings.vim
      source ${vrapperPath}/sneak.vim
      source ${vrapperPath}/tests.vim
      source ${vrapperPath}/ui.vim
      source ${vrapperPath}/windows.vim
      source ${vrapperPath}/zoom.vim
    '';

  xdg.configFile.vrapper.source = config.lib.file.mkOutOfStoreSymlink "${configPath}/vrapper";

  xdg.desktopEntries = {
    Vrapper-Cheatsheet = {
      name = "Vrapper Cheatsheet";
      exec = "${cheatsheet}";
      terminal = false;
      type = "Application";
      categories = ["Development"];
    };
  };
}
