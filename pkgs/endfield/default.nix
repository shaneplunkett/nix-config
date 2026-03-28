{
  lib,
  makeDesktopItem,
  symlinkJoin,
  writeShellScriptBin,
  umu-launcher,
  proton-ge-bin,
  pname ? "endfield",
  location ? "$HOME/Games/endfield",
}:
let
  script = writeShellScriptBin pname ''
    export WINEARCH="win64"
    mkdir -p "${location}"
    export WINEPREFIX="$(readlink -f "${location}")"
    export GAMEID="umu-endfield"
    export STORE="none"
    export PROTON_VERBS="waitforexitandrun"
    export PROTONPATH="${proton-ge-bin.steamcompattool}/"

    # Shader cache
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
    export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
    export MESA_SHADER_CACHE_MAX_SIZE="10G"

    LAUNCHER="$WINEPREFIX/drive_c/Program Files/GRYPHLINK/Launcher.exe"

    PATH=${lib.makeBinPath [ umu-launcher ]}:$PATH

    if [ ! -f "$LAUNCHER" ]; then
      if [ -z "''${1:-}" ]; then
        echo "GRYPHLINK launcher not installed."
        echo "Usage: ${pname} /path/to/GRYPHLINK_installer.exe"
        echo "Download from: https://endfield.gryphline.com/"
        exit 1
      fi
      echo "Installing GRYPHLINK launcher..."
      umu-run "$1"
      shift
    fi

    # Only execute gamemode if it exists on the system
    if command -v gamemoderun > /dev/null 2>&1; then
      gamemode="gamemoderun"
    else
      gamemode=""
    fi

    cd "$WINEPREFIX"
    $gamemode umu-run "$LAUNCHER" "$@"
  '';

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "${script}/bin/${pname} %U";
    comment = "Arknights: Endfield";
    desktopName = "Arknights: Endfield";
    categories = [ "Game" ];
  };
in
symlinkJoin {
  name = pname;
  paths = [
    desktopItems
    script
  ];

  meta = {
    description = "Arknights: Endfield launcher and runner";
    homepage = "https://endfield.gryphline.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
