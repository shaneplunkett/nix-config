{
  lib,
  pythonEnv,
  ffmpeg,
  pulseaudio,
  symlinkJoin,
  makeWrapper,
}:

# Wrapper combining meetscribe-record (provides the `meet` CLI entry-point)
# with meetscribe (provides `meet.subcommands` entry-points) inside one
# Python environment. ffmpeg + pactl are added to PATH so meetscribe's
# subprocess calls resolve at runtime.

symlinkJoin {
  name = "meetscribe-cli";
  paths = [ pythonEnv ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm -f $out/bin/meet
    makeWrapper ${pythonEnv}/bin/meet $out/bin/meet \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg pulseaudio ]}
  '';

  meta = {
    description = "Meetscribe CLI — meet command with subcommands and runtime deps wired in";
    homepage = "https://github.com/pretyflaco/meetscribe";
    license = lib.licenses.gpl3Plus;
    mainProgram = "meet";
    platforms = lib.platforms.linux;
  };
}
