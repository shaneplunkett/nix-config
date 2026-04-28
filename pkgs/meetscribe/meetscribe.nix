{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  meetscribe-record,
  whisperx,
  click,
  reportlab,
  requests,
}:

# Pure Python package — provides the `meet.subcommands` entry-points that
# extend meetscribe-record's `meet` CLI. No `bin/meet` shipped here; the
# wrapper at `pkgs/meetscribe-cli` combines this with meetscribe-record into
# a single working command.
buildPythonPackage rec {
  pname = "meetscribe";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pretyflaco";
    repo = "meetscribe";
    tag = "v${version}";
    hash = "sha256-RZqi8+FZX8o47tESCHsrWNXn/D9XIiPaGvKx0dKOmx4=";
  };

  build-system = [ setuptools ];

  dependencies = [
    meetscribe-record
    whisperx
    click
    reportlab
    requests
  ];

  pythonImportsCheck = [ "meet" ];

  meta = {
    description = "Fully local meeting transcription with diarization, summaries, and markdown/PDF output";
    homepage = "https://github.com/pretyflaco/meetscribe";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
