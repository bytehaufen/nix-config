{
  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";

      # Let WAYLAND_DISPLAY be forwarded
      AcceptEnv = ["WAYLAND_DISPLAY"];
      X11Forwarding = true;
    };
    openFirewall = true;

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
