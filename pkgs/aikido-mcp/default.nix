{
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "aikido-mcp";
  version = "1.0.14";

  src = fetchurl {
    url = "https://registry.npmjs.org/@aikidosec/mcp/-/mcp-${version}.tgz";
    hash = "sha256-JY1jcDWtHUV7wN7L5b/OiZZlIExBn8HncNyfj9fJB2E=";
  };

  sourceRoot = "package";
  npmDepsHash = "sha256-DnMdIOJaB0w8nEbhsyvvMtaiQ/xp0VPGAIbpyX0jOxY=";
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script { };
}
