{
  fetchFromGitHub,
  librepods,
  nix-update-script,
}:

# The harveywuk/airpods Noctalia plugin drives a patched librepods: it reads
# the daemon's status.json and needs the `status`, ca:, onebud: and adaptive:
# verbs on librepods-ctl, none of which upstream has. The fork is upstream's
# linux/ subtree (forked at 29a914c, 2026-05-19) moved to the repo root, so
# the build is nixpkgs' librepods pointed at a different tree.
librepods.overrideAttrs (_: {
  pname = "librepods-noctalia";
  version = "0-unstable-2026-08-26";

  src = fetchFromGitHub {
    owner = "harveywuk";
    repo = "librepods";
    rev = "4ed49df0b301ac3e6fba9c81dfbbb6726cc52201";
    hash = "sha256-Ygoqz5lnGMwZkys+Q4c4pyAUI0llvpGZ/ij5E91CkAg=";
  };

  sourceRoot = "source";

  # CMakeLists includes CTest, which builds the test suite by default.
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
