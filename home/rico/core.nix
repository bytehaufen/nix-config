{vars, ...}: {
  # Let Home manager manage him self 🥚🐔
  programs.home-manager.enable = true;

  home = {
    inherit (vars) username;
    homeDirectory = "/home/${vars.username}";
    stateVersion = "25.05";
    extraOutputsToInstall = ["doc" "devdoc"];
  };
  news.display = "silent";
  manual.manpages.enable = true;
}
