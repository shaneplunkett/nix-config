{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.11-unstable-2026-05-05";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "2508d8e299815010aace3006e58e977ba1360587";
    hash = "sha256-mSercyKWsJ8jYHdCivOzQT3CYazCqCujGmNrxQKlvls=";
  };

  postPatch = ''
    cp ${./tweakcc-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-gAL5WsYvA6J5957BE5saVsFdfz7bF5kp67xwHsXukGE=";
  npmDepsFetcherVersion = 2;

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
