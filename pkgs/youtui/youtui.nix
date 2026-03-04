{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  makeWrapper,
  alsa-lib,
  dbus,
  yt-dlp,
}:
rustPlatform.buildRustPackage {
  pname = "youtui";
  version = "0.0.36";

  src = fetchFromGitHub {
    owner = "nick42d";
    repo = "youtui";
    rev = "youtui/v0.0.36";
    hash = "sha256-+pQP+ho/M7W9mG2b//xu7mAZGGO02QGk9TOYJ+b+SSY=";
  };

  cargoHash = "sha256-HF2ahqCJldZgWjA+PMnS3dHUGlLM43WlnN88Xgij6KM=";

  cargoBuildFlags = [ "-p" "youtui" ];
  cargoTestFlags = [ "-p" "youtui" ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    dbus
  ];

  postInstall = ''
    wrapProgram $out/bin/youtui \
      --prefix PATH : ${lib.makeBinPath [ yt-dlp ]}
  '';

  meta = {
    description = "A simple TUI YouTube Music player written in Rust";
    homepage = "https://github.com/nick42d/youtui";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "youtui";
  };
}
