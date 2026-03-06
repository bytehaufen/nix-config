{inputs, ...}: {
  # Adds pkgs.stable == inputs.nixpkgsStable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = import inputs.nixpkgsStable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  # Enable JavaFX for jdk
  jdk = _: prev: {
    jdk = inputs.nixpkgsStable.legacyPackages.${prev.stdenv.hostPlatform.system}.jdk.override {enableJavaFX = true;};
  };

  workaholick = _: prev: {
    inherit (inputs.workaholick.packages.${prev.stdenv.hostPlatform.system}) workaholick;
  };
}
