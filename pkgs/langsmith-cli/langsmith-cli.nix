{
  lib,
  fetchurl,
  stdenvNoCC,
}:
let
  version = "0.2.21";

  assetBySystem = {
    aarch64-darwin = "langsmith_darwin_arm64.tar.gz";
    x86_64-darwin = "langsmith_darwin_amd64.tar.gz";
    aarch64-linux = "langsmith_linux_arm64.tar.gz";
    x86_64-linux = "langsmith_linux_amd64.tar.gz";
  };

  hashBySystem = {
    aarch64-darwin = "sha256-dTueRTD48/uRV0kMLtIxGf7tT1TEJdmVgz9Nhjb1owI=";
    x86_64-darwin = "sha256-Ap7uMRCzIsRnbQQ6KX7cNF8CMbbkW+tKcgdCTT03XII=";
    aarch64-linux = "sha256-CHEiEQG/NdelZJYG3q+dkEJCBn1tW18dBNssedpIfhM=";
    x86_64-linux = "sha256-Sb9DGqmfxcFzjsJjnZDWsFa1EquGEXTHB2WIe2LB3DY=";
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assetBySystem.${system} or (throw "langsmith-cli: unsupported system '${system}'");
  hash = hashBySystem.${system} or (throw "langsmith-cli: missing hash for '${system}'");
in
stdenvNoCC.mkDerivation {
  pname = "langsmith-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/langchain-ai/langsmith-cli/releases/download/v${version}/${asset}";
    inherit hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 langsmith "$out/bin/langsmith"
    install -Dm644 LICENSE "$out/share/licenses/langsmith-cli/LICENSE"
    install -Dm644 README.md "$out/share/doc/langsmith-cli/README.md"
    runHook postInstall
  '';

  meta = {
    description = "LangSmith CLI for querying traces, runs, datasets, and evaluators";
    homepage = "https://github.com/langchain-ai/langsmith-cli";
    license = lib.licenses.mit;
    platforms = builtins.attrNames assetBySystem;
    mainProgram = "langsmith";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
