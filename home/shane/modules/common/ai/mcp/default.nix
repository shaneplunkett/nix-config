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
    obsidian = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@mauricio.wolff/mcp-obsidian@latest"
        "${homeDirectory}/Prime"
      ];
    };
    posthog = {
      command = "${pkgs.writeShellScript "posthog-mcp" ''
        POSTHOG_KEY="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/posthog"
        exec ${claudeNodejs}/bin/npx -y mcp-remote@latest \
          https://mcp.posthog.com/mcp \
          --header "x-posthog-api-key:$(cat "$POSTHOG_KEY")"
      ''}";
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
