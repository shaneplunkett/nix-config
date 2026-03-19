{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "tweakcc";
  version = "4.0.11";

  src = fetchFromGitHub {
    owner = "Piebald-AI";
    repo = "tweakcc";
    rev = "v4.0.11";
    hash = "sha256-ZsxQ+WDeYQGZ7nENZQWdY/f/Jz1BINcH7yrwFWKkaMc=";
  };

  postPatch = ''
    cp ${./tweakcc-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-PDpuJKa96HnksgDdndXkmWuDpbkiKgDYDe+GlwPwcic=";

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
