{
  pkgs,
  config,
  homeDirectory,
  ...
}:
let
  claudeNodejs = pkgs.nodejs;

  xeroWrapper = pkgs.writeShellApplication {
    name = "xero-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      claudeNodejs
    ];
    text = ''
      XERO_CLIENT_ID="$(rbw get xero-client-id 2>/dev/null)"
      XERO_CLIENT_SECRET="$(rbw get xero-client-secret 2>/dev/null)"
      export XERO_CLIENT_ID XERO_CLIENT_SECRET
      exec npx -y @xeroapi/xero-mcp-server@latest
    '';
  };

  mcpServers = {

    # Desktop-only: direct local connections
    neovim = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "mcp-neovim-server"
      ];
      env = {
        NVIM_SOCKET_PATH = "/tmp/nvim";
      };
    };

    xero = {
      command = "${xeroWrapper}/bin/xero-mcp-wrapper";
      args = [ ];
    };
  };

in
{
  inherit mcpServers;

  packages = [
    claudeNodejs
  ];
}
