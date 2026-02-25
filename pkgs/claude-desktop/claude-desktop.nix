{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
}:
let
  pname = "claude-desktop";

  # ── Version config (update these values to bump) ─────────────────────
  version = "1.1.4173";
  debVersion = "1.3.14";
  hash = "sha256-pxs90d2sAMqPn6vKWlJEY8cd6sfh6bxj7zgZeqsP8kM=";
  # ─────────────────────────────────────────────────────────────────────

  src = fetchurl {
    url = "https://github.com/aaddrick/claude-desktop-debian/releases/download/v${debVersion}%2Bclaude${version}/claude-desktop_${version}-${debVersion}_amd64.deb";
    inherit hash;
  };
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    dpkg-deb -x $src $TMPDIR/extracted
  '';

  installPhase = ''
    runHook preInstall

    # Electron app and launcher
    mkdir -p $out/lib
    cp -r $TMPDIR/extracted/usr/lib/claude-desktop $out/lib/claude-desktop

    # Icons
    mkdir -p $out/share/icons
    cp -r $TMPDIR/extracted/usr/share/icons/* $out/share/icons/

    # Desktop entry
    mkdir -p $out/share/applications
    cp $TMPDIR/extracted/usr/share/applications/claude-desktop.desktop $out/share/applications/

    # Binary — use the bundled Electron directly
    mkdir -p $out/bin
    cat > $out/bin/claude-desktop <<'LAUNCHER'
    #!/usr/bin/env bash
    source "/usr/lib/claude-desktop/launcher-common.sh"
    setup_logging || exit 1
    setup_electron_env
    detect_display_backend
    electron_exec="ELECTRON_PATH"
    app_path="APP_PATH"
    build_electron_args 'deb'
    electron_args+=("$app_path")
    cd "APP_DIR" || exit 1
    exec "$electron_exec" "''${electron_args[@]}" "$@"
    LAUNCHER
    chmod +x $out/bin/claude-desktop

    # Patch paths in launcher
    substituteInPlace $out/bin/claude-desktop \
      --replace-fail "ELECTRON_PATH" "$out/lib/claude-desktop/node_modules/electron/dist/electron" \
      --replace-fail "APP_PATH" "$out/lib/claude-desktop/node_modules/electron/dist/resources/app.asar" \
      --replace-fail "APP_DIR" "$out/lib/claude-desktop" \
      --replace-fail "/usr/lib/claude-desktop/launcher-common.sh" "$out/lib/claude-desktop/launcher-common.sh"

    # Patch the .desktop file to use our path
    substituteInPlace $out/share/applications/claude-desktop.desktop \
      --replace-fail "/usr/bin/claude-desktop" "$out/bin/claude-desktop" \
      --replace-fail "Icon=claude-desktop" "Icon=claude-desktop"

    runHook postInstall
  '';

  dontConfigure = true;
  dontBuild = true;

  meta = with lib; {
    description = "Claude Desktop for Linux (via aaddrick/claude-desktop-debian)";
    homepage = "https://github.com/aaddrick/claude-desktop-debian";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = pname;
  };
}
