{
  pkgs,
  aiHelpers,
  ...
}:
let
  inherit (aiHelpers) rbwRuntimeEnv;

  aikidoWrapper = pkgs.writeShellApplication {
    name = "aikido-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.aikido-mcp
    ];
    text = ''
      ${rbwRuntimeEnv}
      AIKIDO_API_KEY="$(rbw get aikido-token 2>/dev/null)"
      AIKIDO_MCP_ALL_TOOLS="''${AIKIDO_MCP_ALL_TOOLS:-true}"
      export AIKIDO_API_KEY AIKIDO_MCP_ALL_TOOLS
      exec aikido-mcp
    '';
  };

  context7Wrapper = pkgs.writeShellApplication {
    name = "context7-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.context7-mcp
    ];
    text = ''
      ${rbwRuntimeEnv}
      CONTEXT7_API_KEY="$(rbw get context_7_autograb 2>/dev/null)"
      export CONTEXT7_API_KEY
      exec context7-mcp --transport stdio
    '';
  };

in
{
  programs.mcp = {
    enable = true;

    servers = {
      aikido = {
        command = "${aikidoWrapper}/bin/aikido-mcp-wrapper";
        args = [ ];
        env = {
          AIKIDO_MCP_ALL_TOOLS = "true";
        };
      };

      context7 = {
        command = "${context7Wrapper}/bin/context7-mcp-wrapper";
        args = [ ];
      };

      posthog = {
        url = "https://mcp.posthog.com/mcp";
      };
    };
  };
}
