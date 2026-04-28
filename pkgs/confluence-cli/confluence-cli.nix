{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "confluence-cli";
  version = "1.33.2";

  src = fetchFromGitHub {
    owner = "pchuri";
    repo = "confluence-cli";
    rev = "v${version}";
    hash = "sha256-P9eqTfKYFNFtMmpONDnjw9NlTj/OiihUoNpLDUIX4lg=";
  };

  npmDepsHash = "sha256-xSqo4+rC+OK+uIi+1pWeL+e1FiwFfwNUI9IDNRVtq/U=";

  dontNpmBuild = true;

  meta = {
    description = "Confluence CLI — read, search, create, and update pages from the terminal";
    homepage = "https://github.com/pchuri/confluence-cli";
    license = lib.licenses.mit;
    mainProgram = "confluence";
  };
}
