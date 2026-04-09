{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.11-unstable-2026-04-09";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "b7f26eb9c545a26ef4c9a561d5b6fb6ff4b7039d";
    hash = "sha256-ylYVWoBaPnGcUIMTpRC3wKUq4oiHqAy9on2PT69df8U=";
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
