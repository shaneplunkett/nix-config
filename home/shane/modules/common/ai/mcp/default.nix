{
  pkgs,
  homeDirectory,
  ...
}:
let
  claudeNodejs = pkgs.nodejs;

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
  };

in
{
  inherit mcpServers;

  packages = [
    claudeNodejs
  ];
}
