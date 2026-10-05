{
  pkgs,
  aiHelpers,
  ...
}:
let
  inherit (aiHelpers) rbwRuntimeEnv;

  context7Wrapper = pkgs.writeShellApplication {
    name = "context7-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.context7-mcp
    ];
    text = ''
      ${rbwRuntimeEnv}
      CONTEXT7_API_KEY="$(rbw get context7-api-key 2>/dev/null)" || true
      if [ -z "$CONTEXT7_API_KEY" ]; then
        echo "context7-mcp: could not read context7-api-key from rbw. If rbw is locked, run rbw unlock in a terminal." >&2
        exit 1
      fi
      export CONTEXT7_API_KEY
      exec context7-mcp --transport stdio
    '';
  };

in
{
  programs.mcp = {
    enable = true;

    servers = {
      context7 = {
        command = "${context7Wrapper}/bin/context7-mcp-wrapper";
        args = [ ];
      };

      linear-personal = {
        url = "https://mcp.linear.app/mcp";
      };
    };
  };
}
