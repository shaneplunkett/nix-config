{
  pkgs,
  config,
  homeDirectory,
  ...
}:
let
  claudeNodejs = pkgs.nodejs;

  xero-wrapper = pkgs.writeShellScript "xero-mcp-wrapper" ''
    export XERO_CLIENT_ID=$(${pkgs.rbw}/bin/rbw get xero-client-id 2>/dev/null)
    export XERO_CLIENT_SECRET=$(${pkgs.rbw}/bin/rbw get xero-client-secret 2>/dev/null)
    exec ${claudeNodejs}/bin/npx -y @xeroapi/xero-mcp-server@latest
  '';

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
      command = "${xero-wrapper}";
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
