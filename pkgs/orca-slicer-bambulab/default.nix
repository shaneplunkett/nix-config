{
  lib,
  fetchurl,
  appimageTools,
  libwebp,
}:

let
  pname = "orca-slicer-bambulab";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/FULU-Foundation/OrcaSlicer-bambulab/releases/download/v${version}/OrcaSlicer-BMCU_Linux_AppImage_ubuntu24.04_amd64_${version}.AppImage";
    hash = "sha256-+5SPwjXBKRb93Kjt30RnjKhsk2pLFKzHDXXCvSIGeZQ=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;

    postExtract = ''
      substituteInPlace $out/libexec/orca-slicer-env \
        --replace-fail 'export LD_LIBRARY_PATH="$PRIVATE_LIB_DIR:$APPDIR/bin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
                       'export LD_LIBRARY_PATH="${libwebp}/lib:$PRIVATE_LIB_DIR:$APPDIR/bin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
        --replace-fail 'export LD_LIBRARY_PATH="$APPDIR/bin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"' \
                       'export LD_LIBRARY_PATH="${libwebp}/lib:$APPDIR/bin''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"'
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraPkgs = pkgs: [
    pkgs.libsoup_3
    pkgs.libwebp
    pkgs.webkitgtk_4_1
  ];

  extraInstallCommands = ''
    mv $out/bin/${pname} $out/bin/orca-slicer

    desktop_file="$(find ${appimageContents} -maxdepth 2 -name '*.desktop' -print -quit)"
    if [ -n "$desktop_file" ]; then
      install -m 444 -D "$desktop_file" $out/share/applications/orca-slicer-bambulab.desktop
      substituteInPlace $out/share/applications/orca-slicer-bambulab.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=orca-slicer' || true
    fi

    icon_file="$(find ${appimageContents} -maxdepth 3 \( -name '*.png' -o -name '*.svg' \) -print -quit)"
    if [ -n "$icon_file" ]; then
      install -m 444 -D "$icon_file" $out/share/icons/hicolor/512x512/apps/orca-slicer-bambulab."''${icon_file##*.}"
    fi
  '';

  meta = {
    description = "FULU Foundation fork of OrcaSlicer with restored BambuNetwork support";
    homepage = "https://github.com/FULU-Foundation/OrcaSlicer-bambulab";
    license = lib.licenses.agpl3Only;
    mainProgram = "orca-slicer";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
