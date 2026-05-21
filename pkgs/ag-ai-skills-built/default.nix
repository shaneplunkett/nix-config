{
  lib,
  stdenv,
  bash,
  yq-go,
  src,
  installScript,
  normaliseFrontmatter ? false,
}:

stdenv.mkDerivation {
  pname = "ag-ai-skills-built${lib.optionalString normaliseFrontmatter "-codex"}";
  version = "0";

  inherit src;

  nativeBuildInputs = [
    yq-go
    bash
  ];

  dontConfigure = true;
  dontInstall = true;

  buildPhase = ''
    runHook preBuild
    cp ${installScript} ./install.sh
    mkdir -p $out
    bash ./install.sh "$out"
    ${lib.optionalString normaliseFrontmatter ''
      find "$out" -name SKILL.md -exec sed -i '1s/^-----$/---/' {} +
    ''}
    runHook postBuild
  '';
}
