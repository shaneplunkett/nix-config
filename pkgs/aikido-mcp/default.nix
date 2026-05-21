{
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "aikido-mcp";
  version = "1.0.7";

  src = fetchurl {
    url = "https://registry.npmjs.org/@aikidosec/mcp/-/mcp-${version}.tgz";
    hash = "sha256-/G9PY0526/r1kcapSgWK8FbpDAsodzm0OrrkfnL4MCY=";
  };

  sourceRoot = "package";
  npmDepsHash = "sha256-V0RpcQJKHKsEF21NCBYDRud2wE+I7L7Gwpvb7u6WtTw=";
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script { };
}
