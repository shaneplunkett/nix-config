{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  click,
  numpy,
}:

# Built as a Python package (not application) so it composes inside
# `python3.withPackages` — the `meet` entry-point script is still generated
# from pyproject.toml, but the package is also importable as `meet_record`
# by meetscribe.
buildPythonPackage rec {
  pname = "meetscribe-record";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pretyflaco";
    repo = "meetscribe-record";
    tag = "v${version}";
    hash = "sha256-HbdjlySlT6uQrvpMqK3/okwZAHKeiBx9Hd1IQDekQJI=";
  };

  build-system = [ setuptools ];

  dependencies = [
    click
    numpy
  ];

  pythonImportsCheck = [ "meet_record" ];

  meta = {
    description = "Lightweight capture-only subset of meetscribe";
    homepage = "https://github.com/pretyflaco/meetscribe-record";
    license = lib.licenses.gpl3Plus;
    mainProgram = "meet";
    platforms = lib.platforms.linux;
  };
}
