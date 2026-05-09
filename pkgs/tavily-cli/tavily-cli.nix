{
  lib,
  stdenvNoCC,
  makeWrapper,
  curl,
  jq,
  bash,
}:
stdenvNoCC.mkDerivation {
  pname = "tavily-cli";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 tavily.sh "$out/bin/.tavily-unwrapped"
    makeWrapper "$out/bin/.tavily-unwrapped" "$out/bin/tavily" \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          jq
          bash
        ]
      }
    runHook postInstall
  '';

  meta = {
    description = "Tavily CLI — LLM-optimised web search and extraction (custom shell wrapper around the Tavily HTTP API)";
    homepage = "https://tavily.com";
    license = lib.licenses.mit;
    mainProgram = "tavily";
  };
}
