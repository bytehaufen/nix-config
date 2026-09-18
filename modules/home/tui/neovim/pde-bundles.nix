{
  lib,
  fetchurl,
  jq,
  vscode-extensions,
  vscode-utils,
}: let
  # JDT LS no longer includes this API, which PDE's e4 contexts require.
  eventApi = fetchurl {
    url = "https://repo.maven.apache.org/maven2/org/osgi/org.osgi.service.event/1.4.1/org.osgi.service.event-1.4.1.jar";
    hash = "sha256-nxHGiYDb2TGFDz8n/Hw14dcQ7Mco/ocr1teGzX5Le14=";
  };
  javaDebug = vscode-extensions.vscjava.vscode-java-debug;
in
  vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "yaozheng";
      name = "vscode-pde";
      version = "0.11.1";
      hash = "sha256-CAllsD/jwG/Noobb1upb6c6XWSd/uGK1U5dyxCiFCsE=";
    };

    nativeBuildInputs = [jq];
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/java/pde"
      # Follow the extension's bundle manifest, not a glob over arbitrary JARs.
      jq -r '.contributes.javaExtensions[]' package.json | while IFS= read -r bundle; do
        install -m444 "$bundle" "$out/share/java/pde/"
      done
      install -m444 ${eventApi} "$out/share/java/pde/org.osgi.service.event-1.4.1.jar"
      debugJars=(${javaDebug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar)
      if [ "''${#debugJars[@]}" -ne 1 ] || [ ! -r "''${debugJars[0]}" ]; then
        echo "Expected exactly one readable Java debug bundle" >&2
        exit 1
      fi
      debugName=$(basename "''${debugJars[0]}")
      install -m444 "''${debugJars[0]}" "$out/share/java/pde/$debugName"
      jq --arg dir "$out/share/java/pde/" --arg debug "$out/share/java/pde/$debugName" \
        '[.contributes.javaExtensions[] | $dir + (split("/") | last)] + [$dir + "org.osgi.service.event-1.4.1.jar", $debug]' \
        package.json > "$out/share/java/pde/bundles.json"
      install -m444 package.json "$out/share/java/pde/package.json"
      runHook postInstall
    '';

    meta = {
      description = "PDE importer and target-platform support bundles for JDT LS";
      homepage = "https://github.com/testforstephen/vscode-pde";
      license = lib.licenses.epl10;
      sourceProvenance = [lib.sourceTypes.binaryBytecode];
      platforms = lib.platforms.linux;
    };
  }
