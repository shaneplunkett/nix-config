{
  config,
  pkgs,
  lib,
  ...
}:
let
  agentSlack = pkgs.agent-slack;

  tokenPath = config.age.secrets.slack-token.path;
  cookiePath = config.age.secrets.slack-cookie-d.path;

  envLoader = ''
    --argv0 agent-slack \
    --run '
    export SLACK_WORKSPACE_URL="''${SLACK_WORKSPACE_URL:-https://autograb.slack.com}"
    if [ -r "${tokenPath}" ]; then
      export SLACK_TOKEN="''${SLACK_TOKEN:-$(<"${tokenPath}")}"
    fi
    if [ -r "${cookiePath}" ]; then
      export SLACK_COOKIE_D="''${SLACK_COOKIE_D:-$(<"${cookiePath}")}"
    fi
    '
  '';

  # Linux: upstream ships a Bun-compiled standalone binary with an embedded
  # script appended as a "magic trailer". autoPatchelfHook strips the trailer
  # and breaks dispatch (binary falls back to plain Bun mode). Use raw patchelf
  # for interpreter only, with dontStrip so the trailer survives. Also ensure
  # LD_LIBRARY_PATH covers libgcc_s for runtime symbol resolution.
  agentSlackLinux = pkgs.stdenv.mkDerivation {
    pname = "agent-slack-wrapped";
    version = agentSlack.version or "unknown";
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;
    nativeBuildInputs = [
      pkgs.patchelf
      pkgs.makeWrapper
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${agentSlack}/bin/agent-slack $out/bin/.agent-slack-unwrapped
      chmod +w $out/bin/.agent-slack-unwrapped
      patchelf --set-interpreter "$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)" \
        $out/bin/.agent-slack-unwrapped
    '';
    postFixup = ''
      makeWrapper $out/bin/.agent-slack-unwrapped $out/bin/agent-slack \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]} \
        ${envLoader}
    '';
    meta = (agentSlack.meta or { }) // {
      description = "agent-slack patched for NixOS and wrapped to auto-load tokens from agenix";
      mainProgram = "agent-slack";
    };
  };

  agentSlackDarwin = pkgs.symlinkJoin {
    name = "agent-slack-wrapped-${agentSlack.version or "unknown"}";
    paths = [ agentSlack ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      mv $out/bin/agent-slack $out/bin/.agent-slack-unwrapped
      makeWrapper $out/bin/.agent-slack-unwrapped $out/bin/agent-slack ${envLoader}
    '';
    meta = (agentSlack.meta or { }) // {
      description = "agent-slack wrapped to auto-load tokens from agenix";
      mainProgram = "agent-slack";
    };
  };

  agentSlackWrapped = if pkgs.stdenv.isDarwin then agentSlackDarwin else agentSlackLinux;
in
{
  home.packages = [ agentSlackWrapped ];
}
