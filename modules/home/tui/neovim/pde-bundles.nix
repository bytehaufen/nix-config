{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  jq,
}: let
  # JDT LS no longer includes this API, which PDE's e4 contexts require.
  eventApi = fetchurl {
    url = "https://repo.maven.apache.org/maven2/org/osgi/org.osgi.service.event/1.4.1/org.osgi.service.event-1.4.1.jar";
    hash = "sha256-nxHGiYDb2TGFDz8n/Hw14dcQ7Mco/ocr1teGzX5Le14=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "vscode-pde-bundles";
    version = "0.11.1";

    src = fetchurl {
      url = "https://yaozheng.gallery.vsassets.io/_apis/public/gallery/publisher/yaozheng/extension/vscode-pde/0.11.1/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
      hash = "sha256-CAllsD/jwG/Noobb1upb6c6XWSd/uGK1U5dyxCiFCsE=";
    };

    nativeBuildInputs = [unzip jq];
    unpackPhase = ''
      runHook preUnpack
      unzip -q "$src"
      runHook postUnpack
    '';
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/java/pde"
      # Follow the extension's bundle manifest, not a glob over arbitrary JARs.
      jq -r '.contributes.javaExtensions[]' extension/package.json | while IFS= read -r bundle; do
        install -m444 "extension/$bundle" "$out/share/java/pde/"
      done
      install -m444 ${eventApi} "$out/share/java/pde/org.osgi.service.event-1.4.1.jar"
      jq --arg dir "$out/share/java/pde/" \
        '[.contributes.javaExtensions[] | $dir + (split("/") | last)] + [$dir + "org.osgi.service.event-1.4.1.jar"]' \
        extension/package.json > "$out/share/java/pde/bundles.json"
      install -m444 extension/package.json "$out/share/java/pde/package.json"
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
