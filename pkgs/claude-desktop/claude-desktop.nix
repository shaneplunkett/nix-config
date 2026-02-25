{
  lib,
  stdenvNoCC,
  fetchurl,
  electron,
  p7zip,
  icoutils,
  nodePackages,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  perl,
}:
let
  pname = "claude-desktop";

  # ── Version config (update these three values to bump) ──────────────
  version = "1.1.4173";
  urlHash = "12766c56e46a0f6bf202bfa397fceafe4468d7de";
  hash = "sha256-4sazmsG32bweAEAEWCJaWW/8rbCf2A0UyxTHKRQSIcw=";
  # ────────────────────────────────────────────────────────────────────

  srcExe = fetchurl {
    url = "https://downloads.claude.ai/releases/win32/x64/${version}/Claude-${urlHash}.exe";
    inherit hash;
  };

  nativeStub = ./claude-native-stub.js;
in
stdenvNoCC.mkDerivation rec {
  inherit pname version;

  src = ./.;

  nativeBuildInputs = [
    p7zip
    nodePackages.asar
    makeWrapper
    imagemagick
    icoutils
    perl
  ];

  desktopItem = makeDesktopItem {
    name = "Claude";
    exec = "claude-desktop %u";
    icon = "claude";
    type = "Application";
    terminal = false;
    desktopName = "Claude";
    genericName = "Claude Desktop";
    comment = "AI Assistant by Anthropic";
    startupWMClass = "Claude";
    startupNotify = true;
    categories = [
      "Office"
      "Utility"
      "Network"
      "Chat"
    ];
    mimeTypes = [ "x-scheme-handler/claude" ];
  };

  buildPhase = ''
    runHook preBuild

    mkdir -p $TMPDIR/build
    cd $TMPDIR/build

    # Extract Windows installer
    7z x -y ${srcExe}
    7z x -y "AnthropicClaude-${version}-full.nupkg"

    # Extract icons from claude.exe
    wrestool -x -t 14 lib/net45/claude.exe -o claude.ico
    icotool -x claude.ico

    for size in 16 24 32 48 64 256; do
      mkdir -p $TMPDIR/build/icons/hicolor/"$size"x"$size"/apps
      install -Dm 644 claude_*"$size"x"$size"x32.png \
        $TMPDIR/build/icons/hicolor/"$size"x"$size"/apps/claude.png
    done

    rm claude.ico

    # Process app.asar
    mkdir -p electron-app
    cp "lib/net45/resources/app.asar" electron-app/
    cp -r "lib/net45/resources/app.asar.unpacked" electron-app/

    cd electron-app
    asar extract app.asar app.asar.contents

    # ── Patch 1: Title bar (enable on Linux) ──────────────────────────
    SEARCH_BASE="app.asar.contents/.vite/renderer/main_window/assets"
    TARGET_FILE=$(find "$SEARCH_BASE" -type f -name "MainWindowPage-*.js" | head -1)
    if [ -n "$TARGET_FILE" ]; then
      echo "Patching title bar in: $TARGET_FILE"
      perl -i -pe \
        's{if\(!(\w+)\s*&&\s*(\w+)\)}{if($1 && $2)}g' \
        "$TARGET_FILE"
    fi

    # ── Patch 2-5: index.js patches ──────────────────────────────────
    INDEX_FILE="app.asar.contents/.vite/build/index.js"
    if [ -f "$INDEX_FILE" ]; then
      # Platform detection: add Linux support for Claude Code binary
      echo "Patching platform detection..."
      sed -i 's/if(process.platform==="win32")return"win32-x64";throw/if(process.platform==="win32")return"win32-x64";if(process.platform==="linux")return process.arch==="arm64"?"linux-arm64":"linux-x64";throw/g' "$INDEX_FILE"

      # Origin validation: fix file:// protocol check
      echo "Patching origin validation..."
      sed -i -E 's/e\.protocol==="file:"\&\&[a-zA-Z]+\.app\.isPackaged===!0/e.protocol==="file:"/g' "$INDEX_FILE"

      # Tray icon: use dark variant on Linux
      echo "Patching tray icon theme..."
      sed -i -E 's/:([a-zA-Z])="TrayIconTemplate\.png"/:\1=require("electron").nativeTheme.shouldUseDarkColors?"TrayIconTemplate-Dark.png":"TrayIconTemplate.png"/g' "$INDEX_FILE"

      # Window blur: fix quick submit hide
      echo "Patching window blur..."
      sed -i 's/e\.hide()/e.blur(),e.hide()/g' "$INDEX_FILE"
    fi

    # ── Install JS native stub ────────────────────────────────────────
    echo "Installing native stub..."
    mkdir -p app.asar.contents/node_modules/@ant/claude-native
    mkdir -p app.asar.unpacked/node_modules/@ant/claude-native
    cp ${nativeStub} app.asar.contents/node_modules/@ant/claude-native/index.js
    cp ${nativeStub} app.asar.unpacked/node_modules/@ant/claude-native/index.js

    # Swift addon stub
    mkdir -p app.asar.contents/node_modules/@ant/claude-swift
    mkdir -p app.asar.unpacked/node_modules/@ant/claude-swift
    echo "module.exports = {};" > app.asar.contents/node_modules/@ant/claude-swift/index.js
    echo "module.exports = {};" > app.asar.unpacked/node_modules/@ant/claude-swift/index.js

    # ── Tray icons ────────────────────────────────────────────────────
    mkdir -p app.asar.contents/resources
    cp ../lib/net45/resources/Tray* app.asar.contents/resources/ 2>/dev/null || true

    # Fix icon alpha for Linux tray visibility
    for icon in app.asar.contents/resources/TrayIconTemplate*.png; do
      if [ -f "$icon" ]; then
        convert "$icon" -channel A -fx "a>0?1:0" "$icon" 2>/dev/null || true
      fi
    done

    # ── i18n locale files ─────────────────────────────────────────────
    mkdir -p app.asar.contents/resources/i18n
    cp ../lib/net45/resources/*.json app.asar.contents/resources/i18n/ 2>/dev/null || true

    # Repack
    asar pack app.asar.contents app.asar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/$pname
    cp -r $TMPDIR/build/electron-app/app.asar $out/lib/$pname/
    cp -r $TMPDIR/build/electron-app/app.asar.unpacked $out/lib/$pname/

    mkdir -p $out/share/icons
    cp -r $TMPDIR/build/icons/* $out/share/icons

    mkdir -p $out/share/applications
    install -Dm0644 {${desktopItem},$out}/share/applications/Claude.desktop

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/$pname \
      --add-flags "$out/lib/$pname/app.asar" \
      --add-flags "\''${CLAUDE_USE_WAYLAND:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,UseOzonePlatform --gtk-version=4}" \
      --set-default GDK_BACKEND "x11" \
      --set ELECTRON_FORCE_IS_PACKAGED "true" \
      --set CHROME_DESKTOP "Claude.desktop" \
      --prefix XDG_DATA_DIRS : "$out/share"

    runHook postInstall
  '';

  dontUnpack = true;
  dontConfigure = true;

  meta = with lib; {
    description = "Claude Desktop for Linux";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = pname;
  };
}
