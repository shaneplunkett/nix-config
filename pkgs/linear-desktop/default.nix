{
  copyDesktopItems,
  curl,
  electron_41,
  fetchurl,
  gnugrep,
  lib,
  makeDesktopItem,
  makeWrapper,
  nix-update,
  p7zip,
  stdenv,
  writeShellApplication,
}:
let
  version = "1.32.1";

  desktopItem = makeDesktopItem {
    name = "linear";
    desktopName = "Linear";
    comment = "Issue tracking and project planning";
    # linear-cli already owns bin/linear in the home profile.
    exec = "linear-desktop %U";
    icon = "linear";
    categories = [ "Office" ];
    mimeTypes = [ "x-scheme-handler/linear" ];
    startupWMClass = "linear";
  };

  updateScript = writeShellApplication {
    name = "update-linear-desktop";
    runtimeInputs = [
      curl
      gnugrep
      nix-update
    ];
    text = ''
      version="$(curl --fail --silent --show-error --head https://releases.linear.app/windows \
        | grep --only-matching --perl-regexp 'filename="Linear Setup \K[0-9.]+(?=\.exe")')"
      exec nix-update --flake linear-desktop --version "$version"
    '';
  };
in
stdenv.mkDerivation {
  pname = "linear-desktop";
  inherit version;

  # Linear only ships Windows and macOS desktop builds. The Windows NSIS
  # installer wraps a plain Electron app with no native modules (its only
  # bundled dependency is @electron/remote), so the app.asar runs unmodified
  # on Linux under a matching-major nixpkgs Electron.
  src = fetchurl {
    name = "Linear-Setup-${version}.exe";
    url = "https://releases.linear.app/Linear%20Setup%20${version}.exe";
    hash = "sha256-jrNKwFNMOZSz1ijl+4pndVtwH4u+u/wXfn4C7T3GbNU=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    p7zip
  ];

  desktopItems = [ desktopItem ];

  buildPhase = ''
    runHook preBuild

    mkdir installer app-bundle
    7z x -y "$src" -oinstaller >/dev/null
    7z x -y 'installer/$PLUGINSDIR/app-64.7z' -oapp-bundle >/dev/null

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 app-bundle/resources/app.asar "$out/share/linear/app.asar"
    install -Dm644 ${./icon.png} "$out/share/icons/hicolor/512x512/apps/linear.png"

    # electron-updater sees an unpackaged app and skips update checks, so the
    # Windows-only auto-update path never runs.
    makeWrapper ${electron_41}/bin/electron "$out/bin/linear-desktop" \
      --unset ELECTRON_RUN_AS_NODE \
      --set ELECTRON_OZONE_PLATFORM_HINT auto \
      --add-flags "$out/share/linear/app.asar" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations"

    runHook postInstall
  '';

  passthru = {
    inherit updateScript;
  };

  meta = {
    description = "Issue tracking and project planning (unofficial Linux package)";
    homepage = "https://linear.app/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "linear-desktop";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
