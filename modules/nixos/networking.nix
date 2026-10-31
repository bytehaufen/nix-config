{
  # Service to discover network printers in network and make machines available
  # through {hostname}.local domain
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    settings.publish = {
      disable-publishing = false;
      publish-domain = true;
      disable-user-service-publishing = false;
      publish-addresses = true;
    };
  };
}
