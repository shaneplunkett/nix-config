{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.11-unstable-2026-03-26";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "69c8471b041f5404feb56bbd7d7ca1a6c92af88f";
    hash = "sha256-Wu0S8RX/sEPg0ijJcQ9SLvbJ/+Q8uyTUp7yiGY5Iaeo=";
  };

  postPatch = ''
    cp ${./tweakcc-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-FmV0qLMVOuHqZ7yg7uqO0YCgF58ql9olz+KCqlbeuVY=";

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];

  npmBuildScript = "build";

  meta = {
    description = "Customise Claude Code themes and UI";
    homepage = "https://github.com/Piebald-AI/tweakcc";
    license = lib.licenses.mit;
    mainProgram = "tweakcc";
  };
}
