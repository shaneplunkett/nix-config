{
  pkgs,
  lib,
  ...
}:
let
  agentSlack = pkgs.agent-slack;

  envLoader = ''
    --argv0 agent-slack \
    --run '
    export SLACK_WORKSPACE_URL="''${SLACK_WORKSPACE_URL:-https://autograb.slack.com}"
    if [ -z "''${SLACK_TOKEN:-}" ]; then
      SLACK_TOKEN="$(${pkgs.rbw}/bin/rbw get slack-token 2>/dev/null)"
      [ -n "$SLACK_TOKEN" ] && export SLACK_TOKEN
    fi
    if [ -z "''${SLACK_COOKIE_D:-}" ]; then
      SLACK_COOKIE_D="$(${pkgs.rbw}/bin/rbw get slack-cookie-d 2>/dev/null)"
      [ -n "$SLACK_COOKIE_D" ] && export SLACK_COOKIE_D
    fi
    '
  '';

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
      description = "agent-slack patched for NixOS and wrapped to auto-load tokens from rbw";
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
      description = "agent-slack wrapped to auto-load tokens from rbw";
      mainProgram = "agent-slack";
    };
  };

  agentSlackWrapped = if pkgs.stdenv.isDarwin then agentSlackDarwin else agentSlackLinux;
in
{
  home.packages = [ agentSlackWrapped ];
}
