{
  pkgs,
  ...
}:
let
  inherit (pkgs) nodejs;

  rbwRuntimeEnv = ''
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      runtime_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      if [ -d "$runtime_dir" ]; then
        export XDG_RUNTIME_DIR="$runtime_dir"
      fi
    fi
  '';

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

  xeroWrapper = pkgs.writeShellApplication {
    name = "xero-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.xero-mcp-server
    ];
    text = ''
      ${rbwRuntimeEnv}
      XERO_CLIENT_ID="$(rbw get xero-client-id 2>/dev/null)"
      XERO_CLIENT_SECRET="$(rbw get xero-client-secret 2>/dev/null)"
      export XERO_CLIENT_ID XERO_CLIENT_SECRET
      exec ${pkgs.xero-mcp-server}/bin/@xeroapi/xero-mcp-server
    '';
  };

in
{
  programs.mcp = {
    enable = true;

    servers = {
      # Desktop-only: direct local connections.
      neovim = {
        command = "${nodejs}/bin/npx";
        args = [
          "-y"
          "mcp-neovim-server"
        ];
        env = {
          NVIM_SOCKET_PATH = "/tmp/nvim";
        };
      };

      aikido = {
        command = "${aikidoWrapper}/bin/aikido-mcp-wrapper";
        args = [ ];
        env = {
          AIKIDO_MCP_ALL_TOOLS = "true";
        };
      };

      xero = {
        command = "${xeroWrapper}/bin/xero-mcp-wrapper";
        args = [ ];
      };
    };
  };

  home.packages = [
    nodejs
  ];
}
