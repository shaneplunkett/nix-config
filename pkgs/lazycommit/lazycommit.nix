{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "lazycommit";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "m7medVision";
    repo = "lazycommit";
    rev = "v${version}";
    hash = "sha256-DD3DXTev8WHNkAYDrPY2PISuA8WwKuK0GCLebpn01Rg=";
  };

  vendorHash = "sha256-4OPCUWXxsAnzxsqZPHhjvhxQQf5Knm7nGqrdjH4I4YY=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "AI-powered commit message generator for lazygit";
    homepage = "https://github.com/m7medVision/lazycommit";
    license = lib.licenses.mit;
    mainProgram = "lazycommit";
  };
}
