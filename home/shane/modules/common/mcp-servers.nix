{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

  mcphubWrapper =
    server:
    pkgs.writeShellScript "mcphub-${server}" ''
      BEARER_PATH="${config.age.secrets.mcphub-bearer.path}"
      AUTH="Bearer $(cat "$BEARER_PATH")"
      exec ${claudeNodejs}/bin/npx -y mcp-remote@latest \
        'http://localhost:3000/mcp/${server}' \
        --header "Authorization:$AUTH" \
        --allow-http
    '';

  mkMcpHubServer = server: {
    command = "${mcphubWrapper server}";
    args = [ ];
  };

  mcpServers = {
    # MCPHub-proxied servers (local docker compose @ localhost:3000)
    memory = mkMcpHubServer "memory";
    todoist = mkMcpHubServer "todoist";
    github = mkMcpHubServer "github";
    context7 = mkMcpHubServer "context7";
    google-workspace = mkMcpHubServer "google-workspace";
    shadcn = mkMcpHubServer "shadcn";
    tailscale = mkMcpHubServer "tailscale";
    graphiti = mkMcpHubServer "graphiti";
    mcphub-smart = mkMcpHubServer "smart";

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
        POSTHOG_KEY="${config.age.secrets.posthog.path}"
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
