{
  asar,
  buildGoModule,
  copyDesktopItems,
  curl,
  electron_42,
  fetchurl,
  jq,
  lib,
  makeDesktopItem,
  makeWrapper,
  nix-update,
  node-gyp,
  nodejs_24,
  p7zip,
  python3,
  stdenv,
  writeShellApplication,
}:
let
  version = "7.452.1";

  nativeHost = buildGoModule {
    pname = "granola-meet-consent-host";
    inherit version;
    src = ./native-host;
    vendorHash = null;
    env.CGO_ENABLED = "0";

    meta = {
      description = "Chrome Native Messaging bridge for Granola on Linux";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "meet-consent-host";
    };
  };

  desktopItem = makeDesktopItem {
    name = "granola";
    desktopName = "Granola";
    comment = "AI notepad for meetings";
    exec = "granola %U";
    icon = "granola";
    categories = [ "Office" ];
    startupWMClass = "Granola";
  };

  updateScript = writeShellApplication {
    name = "update-granola";
    runtimeInputs = [
      curl
      jq
      nix-update
    ];
    text = ''
      version="$(curl --fail --silent --show-error https://api.granola.ai/v1/get-versions | jq --raw-output .production)"
      exec nix-update --flake granola --version "$version"
    '';
  };
in
stdenv.mkDerivation {
  pname = "granola";
  inherit version;

  src = fetchurl {
    url = "https://dr2v7l5emb758.cloudfront.net/${version}/Granola-${version}-win-x64.exe";
    hash = "sha256-esj8pNeZU+rhUJ2a1xNAxxq2uuR5DIQtGoHr8/iJIr4=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    asar
    copyDesktopItems
    makeWrapper
    node-gyp
    nodejs_24
    p7zip
    python3
  ];

  desktopItems = [ desktopItem ];

  buildPhase = ''
    runHook preBuild

    mkdir installer app-bundle app
    7z x -y "$src" -oinstaller >/dev/null
    7z x -y 'installer/$PLUGINSDIR/app-64.7z' -oapp-bundle >/dev/null
    asar extract app-bundle/resources/app.asar app

    # In unpackaged mode Granola resolves its tray and meeting-service icons
    # relative to app.getAppPath(). The Windows distribution stores them beside
    # app.asar instead, so recreate the directory expected by the app.
    mkdir -p app/resources
    cp -a app-bundle/resources/icons app/resources/icons

    sqlite_module=app/node_modules/better-sqlite3-multiple-ciphers
    cp ${./binding.gyp} "$sqlite_module/binding.gyp"
    (
      cd "$sqlite_module"
      ${nodejs_24}/bin/node \
        ${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js \
        rebuild \
        --release \
        --target=${electron_42.version} \
        --nodedir=${electron_42.headers}

      # Keep only the runtime binding. Generated makefiles and object files
      # embed build-tool store paths, which would otherwise bloat Granola's
      # runtime closure with node-gyp, Python, and the Electron headers.
      cp build/Release/better_sqlite3.node "$NIX_BUILD_TOP/better_sqlite3.node"
      rm -rf build
      install -Dm755 \
        "$NIX_BUILD_TOP/better_sqlite3.node" \
        build/Release/better_sqlite3.node
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/bin" \
      "$out/share/granola" \
      "$out/share/icons/hicolor/512x512/apps"

    cp -a app "$out/share/granola/app"
    install -Dm755 \
      ${nativeHost}/bin/meet-consent-host \
      "$out/share/granola/native/x64/meet-consent-host"
    install -Dm644 \
      app-bundle/resources/icons/icon.png \
      "$out/share/icons/hicolor/512x512/apps/granola.png"

    cat > "$out/share/granola/com.granola.app.json" <<EOF
    {
      "name": "com.granola.app",
      "description": "Granola meeting notes - consent messaging",
      "path": "$out/share/granola/native/x64/meet-consent-host",
      "type": "stdio",
      "allowed_origins": [
        "chrome-extension://fihphjchjdimokpleomddhnapnobdphn/",
        "chrome-extension://ephifgbopdapgehlpnakaddgmmgcbmjp/",
        "chrome-extension://opaadbjlebbbnmjjgdmdllingedoleml/"
      ]
    }
    EOF

    makeWrapper ${electron_42}/bin/electron "$out/bin/granola" \
      --unset ELECTRON_RUN_AS_NODE \
      --set ELECTRON_OZONE_PLATFORM_HINT auto \
      --add-flags "$out/share/granola/app" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations"

    runHook postInstall
  '';

  passthru = {
    inherit nativeHost updateScript;
  };

  meta = {
    description = "AI notepad for meetings (unofficial Linux package)";
    homepage = "https://www.granola.ai/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "granola";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
