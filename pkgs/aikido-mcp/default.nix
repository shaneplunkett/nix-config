{
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "aikido-mcp";
  version = "1.0.8";

  src = fetchurl {
    url = "https://registry.npmjs.org/@aikidosec/mcp/-/mcp-${version}.tgz";
    hash = "sha256-Gq53/edcbchsFt1IeDWPhhg0W6wYdEc6KcRNX4/uwgI=";
  };

  sourceRoot = "package";
  npmDepsHash = "sha256-Q3QFwfH8M4dTnw1LlP/I3142u9qjMSUGAp3Pf/U2Abw=";
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script { };
}
