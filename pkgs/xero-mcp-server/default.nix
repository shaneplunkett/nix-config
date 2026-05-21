{
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "xero-mcp-server";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "XeroAPI";
    repo = "xero-mcp-server";
    rev = "1b2e9b332086fa0887c8248010b4bc75083491d1";
    hash = "sha256-KJpS7Lw1xQBteZlv3O05u8mASnarPU8ebyXIxTJbwkw=";
  };

  npmDepsHash = "sha256-ifbjeO3V+eQv7dwFbSFq17AlklcsjqJ2WslySWFwUlk=";
}
