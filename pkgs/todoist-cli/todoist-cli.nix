{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "todoist-cli";
  version = "1.57.0";

  src = fetchFromGitHub {
    owner = "Doist";
    repo = "todoist-cli";
    rev = "v${version}";
    hash = "sha256-DFCW2ab97JY6iLi0WRCcCaJ6OdEK9eV5UT7yU71NT9A=";
  };

  npmDepsHash = "sha256-9TtjDsdEYNuzfnh+NEktFVgLqkpzyK/r0kfnPm/f3ZM=";

  npmBuildScript = "build";

  meta = {
    description = "Official Todoist CLI from Doist — agent-friendly with --json/--ndjson output";
    homepage = "https://github.com/Doist/todoist-cli";
    license = lib.licenses.mit;
    mainProgram = "td";
  };
}
