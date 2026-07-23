{
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "xero-mcp-server";
  version = "0.0.17";

  src = fetchFromGitHub {
    owner = "XeroAPI";
    repo = "xero-mcp-server";
    rev = "6d30b7556c17bdaae66c3c605f1cb2ca5704783a";
    hash = "sha256-T6PQP0BuTEiomgsS1Vbj4oWBmB2RLzHJ+hIoEnqD3x8=";
  };

  # The lockfile patch is version-specific; regenerate it on every bump.
  patches = assert version == "0.0.17"; [
    ./package-lock-0.0.17.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-/7ukLCDWMT3r4GpboYNCCf8prF7KgFLApHm35kqQ8nQ=";
}
