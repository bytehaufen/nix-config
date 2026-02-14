{
  pkgs,
  lib,
  config,
  ...
}: let
  targetPkgs = with pkgs; [
    adwaita-icon-theme
    curl
    expat
    freetype
    fontconfig
    fuse3
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk3
    icu
    jdk
    libsecret
    libssh
    libxcrypt-legacy
    libxml2
    ncurses
    perl
    nss
    stdenv.cc.cc
    subversion
    tcsh
    libx11
    libxrender
    libxtst
    zlib
  ];
in {
  config = lib.mkIf config.opts.nixos.programs.nix-ld.enable {
    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];

    environment.systemPackages = [
      #
      pkgs.tcsh
      # Just for analysis of executables
      pkgs.patchelf

      # Create a fhs environment by command `fhs`, so we can run non-nixos packages in nixos!
      (
        let
          base = pkgs.appimageTools.defaultFhsEnvArgs;
          customTargetPkgs = [
            (pkgs.runCommand "ld-lsb-compat" {} ''
              mkdir -p "$out/lib"
              ln -sr "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" "$out/lib/ld-lsb-x86-64.so.3"
              ln -sr "${pkgs.openssl_1_1.out}/lib/libssl.so" "$out/lib/libssl.so.10"
              ln -sr "${pkgs.openssl_1_1.out}/lib/libcrypto.so" "$out/lib/libcrypto.so.10"
              ln -sr "${pkgs.ncurses}/lib/libtinfo.so" "$out/lib/libtinfo.so.5"
            '')
          ];
        in
          pkgs.buildFHSEnv (base
            // {
              name = "fhs";
              targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config] ++ customTargetPkgs ++ targetPkgs;
              profile = "export FHS=1; export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/";
              runScript = "bash";
              extraOutputsToInstall = ["dev"];
            })
      )
    ];

    # Auto resolves hard coded shebangs in scripts e.g. `/bin/bash`
    services.envfs = {
      enable = true;
      extraFallbackPathCommands = ''
        ln -s ${lib.getExe pkgs.tcsh} $out/tcsh
      '';
    };

    programs.nix-ld = {
      enable = true;
      libraries = targetPkgs;
    };
  };
}
