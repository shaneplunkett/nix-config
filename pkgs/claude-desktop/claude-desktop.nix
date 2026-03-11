{
  fetchurl,
  appimageTools,
  makeWrapper,
  lib,
}:
let
  pname = "claude-desktop";

  # ── Version config (update these values to bump) ─────────────────────
  version = "1.1.5749";
  debVersion = "1.3.17";
  hash = "sha256-Wxizu+/7xXBbutS/+euU5QW4ec836CWdUqF+G6Swfzg=";
  # ─────────────────────────────────────────────────────────────────────

  src = fetchurl {
    url = "https://github.com/aaddrick/claude-desktop-debian/releases/download/v${debVersion}%2Bclaude${version}/claude-desktop-${version}-${debVersion}-amd64.AppImage";
    inherit hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname src version;
  };
in
appimageTools.wrapType2 {
  inherit pname src version;

  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/claude-desktop \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    # Install desktop file
    install -m 444 -D ${appimageContents}/io.github.aaddrick.claude-desktop-debian.desktop \
      $out/share/applications/claude-desktop.desktop
    substituteInPlace $out/share/applications/claude-desktop.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=claude-desktop'

    # Install icon
    install -m 444 -D ${appimageContents}/io.github.aaddrick.claude-desktop-debian.png \
      $out/share/icons/hicolor/256x256/apps/claude-desktop.png
  '';

  meta = {
    description = "Claude Desktop for Linux (via aaddrick/claude-desktop-debian)";
    homepage = "https://github.com/aaddrick/claude-desktop-debian";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = pname;
  };
}
