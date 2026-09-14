{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

# Upstream's source flake still has a fake helper hash and ships Windows SQLite
# modules. Use the released Linux payload, including its rebuilt native modules.
appimageTools.wrapAppImage (finalAttrs: {
  pname = "wispr-flow";
  version = "1.0.3+wispr1.6.7";

  src =
    let
      versions = lib.splitString "+wispr" finalAttrs.version;
      portVersion = builtins.elemAt versions 0;
      appVersion = builtins.elemAt versions 1;
    in
    fetchurl {
      url = "https://github.com/wispr-flow-linux/wispr-flow-linux/releases/download/v${finalAttrs.version}/wispr-flow-${appVersion}-${portVersion}-x86_64.AppImage";
      hash = "sha256-T9/evAykYnc20TVc7sX3Bwf8aTkTkxEtDr8FNavIMfA=";
    };

  contents = appimageTools.extract {
    inherit (finalAttrs) pname version src;
    postExtract = ''
      # This runs from the Nix store, not a FUSE mount. Avoid globally disabling
      # Chromium's sandbox; the app still controls its per-window sandbox flags.
      substituteInPlace $out/AppRun \
        --replace-fail "build_electron_args 'appimage'" "build_electron_args 'nix'"
    '';
  };

  extraPkgs = pkgs: [
    pkgs.wl-clipboard
    pkgs.xclip
    pkgs.xsel
    pkgs.at-spi2-core
    pkgs.libsecret
    pkgs.systemd
  ];

  extraInstallCommands = ''
    install -Dm644 ${finalAttrs.contents}/ai.wisprflow.WisprFlow.desktop \
      $out/share/applications/ai.wisprflow.WisprFlow.desktop
    substituteInPlace $out/share/applications/ai.wisprflow.WisprFlow.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=wispr-flow'
    echo 'MimeType=x-scheme-handler/wispr-flow;' \
      >> $out/share/applications/ai.wisprflow.WisprFlow.desktop

    mkdir -p $out/share/icons
    cp -r ${finalAttrs.contents}/usr/share/icons/hicolor $out/share/icons/
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(.*)$"
    ];
  };

  meta = {
    description = "Wispr Flow voice dictation, unofficial Linux port";
    homepage = "https://github.com/wispr-flow-linux/wispr-flow-linux";
    changelog = "https://github.com/wispr-flow-linux/wispr-flow-linux/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    mainProgram = "wispr-flow";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
