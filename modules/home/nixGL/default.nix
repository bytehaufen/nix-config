{
  inputs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.opts.home.nixGL.enable {
    targets.genericLinux.nixGL = {
      inherit (inputs.nixGL) packages;
      defaultWrapper = "mesa";
      installScripts = ["mesa"];
      vulkan.enable = false;
    };
  };
}
