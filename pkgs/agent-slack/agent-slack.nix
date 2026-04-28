{
  lib,
  fetchurl,
  stdenvNoCC,
}:
# Override of upstream's flake — they tag releases without bumping nix/sources.json,
# so their flake builds an old version. Fetch the release asset directly.
let
  version = "0.8.5";

  assetBySystem = {
    aarch64-darwin = "agent-slack-darwin-arm64";
    x86_64-darwin = "agent-slack-darwin-x64";
    aarch64-linux = "agent-slack-linux-arm64";
    x86_64-linux = "agent-slack-linux-x64";
  };

  hashBySystem = {
    aarch64-darwin = "sha256-8TeA13dEzJ6mmXkVjXIPjeBigRAXm0n3Jg7+u00ghAw=";
    x86_64-darwin = "sha256-/9EhcPwkW5I4Vu04/0Rym3LNq3kOWMra4ngnBjx/ImY=";
    aarch64-linux = "sha256-GduevM2nLgE96MBJ1xL/QkjAsKwCjFvG+fGgHXcfIwk=";
    x86_64-linux = "sha256-ymBPKfbdHUNQJp7q6q0T1Y+aWkIoJaPwxpMqRTeKE94=";
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assetBySystem.${system} or (throw "agent-slack: unsupported system '${system}'");
  hash = hashBySystem.${system} or (throw "agent-slack: missing hash for '${system}'");
in
stdenvNoCC.mkDerivation {
  pname = "agent-slack";
  inherit version;

  src = fetchurl {
    url = "https://github.com/stablyai/agent-slack/releases/download/v${version}/${asset}";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/agent-slack"
    runHook postInstall
  '';

  meta = {
    description = "Slack automation CLI for AI agents";
    homepage = "https://github.com/stablyai/agent-slack";
    license = lib.licenses.mit;
    platforms = builtins.attrNames assetBySystem;
    mainProgram = "agent-slack";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
