{
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "aikido-mcp";
  version = "1.0.12";

  src = fetchurl {
    url = "https://registry.npmjs.org/@aikidosec/mcp/-/mcp-${version}.tgz";
    hash = "sha256-zyftLkVpcL4sbYvVaxmxHgnXSfk/5qazMswRgDx2zwc=";
  };

  sourceRoot = "package";
  npmDepsHash = "sha256-zMonyDKIYfvpIRcDaMbvBy/jxgqIyZZ8DxU35wC7Af4=";
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script { };
}
