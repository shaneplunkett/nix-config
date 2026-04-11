{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.11-unstable-2026-04-10";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "5c3784d5fb1516640311c3ee9ab907a6dbf90499";
    hash = "sha256-TPduX4WaCEYZhO3h/3yxfddW2NOzP1VHGlfpBZpDoFg=";
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
