{
  fetchurl,
  appimageTools,
  makeWrapper,
  imagemagick,
  lib,
}:
let
  pname = "capacities";
  version = "1.58.27";

  src = fetchurl {
    url = "https://capacities-desktop-app.fra1.cdn.digitaloceanspaces.com/Capacities-${version}.AppImage";
    sha256 = "140ii8gkacig1zyw47fi6fqp9c6dlac9zw1918zs596mv6ac33wb";
  };

  appimageContents = appimageTools.extractType2 {
    inherit
      pname
      src
      version
      ;
  };
in
appimageTools.wrapType2 {
  inherit
    pname
    src
    version
    ;

  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/capacities \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    # Check for required desktop file
    if [ ! -f ${appimageContents}/capacities.desktop ]; then
      echo "Error: Missing .desktop file in ${appimageContents}"
      exit 1
    else
      # Install and modify the desktop file
      install -m 444 -D ${appimageContents}/capacities.desktop $out/share/applications/capacities.desktop
      substituteInPlace $out/share/applications/capacities.desktop \
        --replace 'Exec=AppRun --no-sandbox' 'Exec=capacities'
    fi

    # Check for required icon file
    if [ ! -f ${appimageContents}/capacities.png ]; then
      echo "Error: Missing icon file in ${appimageContents}"
      exit 1
    else
      # Resize and install the icon
      ${lib.getExe imagemagick} ${appimageContents}/capacities.png -resize 512x512 capacities_512.png
      install -m 444 -D capacities_512.png $out/share/icons/hicolor/512x512/apps/capacities.png
    fi
  '';

  meta = {
    description = "Calm place to make sense of the world and create amazing things";
    homepage = "https://capacities.io/";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = "capacities";
  };
}
