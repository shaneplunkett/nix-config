{
  pkgs,
  config,
  homeDirectory,
  ...
}:
let
  claudeNodejs = pkgs.nodejs;

  xero-wrapper = pkgs.writeShellScript "xero-mcp-wrapper" ''
    export XERO_CLIENT_ID=$(cat ${config.age.secrets.xero-client-id.path})
    export XERO_CLIENT_SECRET=$(cat ${config.age.secrets.xero-client-secret.path})
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
