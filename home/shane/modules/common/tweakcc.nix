{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.6";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "v4.0.6";
    hash = "sha256-MsEKV0Grm0OqeFDPsc98qfh5BtC/zk61KeCEJmo3iR8=";
  };

  # The upstream lockfile is missing cli-spinners — use a regenerated one
  postPatch = ''
    cp ${./tweakcc-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-oAA4iXeVCemwkbSuG3w9bRF7eCxwSSm3IEANSTCNf4A=";

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
