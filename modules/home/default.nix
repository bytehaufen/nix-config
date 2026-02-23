{
  imports = [
    ./agenix # Agenix configuration and secrets
    ./images # My wallpapers etc
    ./gui # Graphical applications
    ./keyboard # Keyboard configuration # TODO: Make this system wide
    ./nix.nix # Nix configuration for non-NixOS
    ./home-options.nix
    ./services # User Services
    ./scripts.nix # Custom scripts
    ./theme # My custom theme
    ./tui # Terminal applications
    ./wayland # Wayland specific GUI applications
  ];
}
