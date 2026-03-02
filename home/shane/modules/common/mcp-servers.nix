{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

  mcphubWrapper = server: pkgs.writeShellScript "mcphub-${server}" ''
    BEARER_PATH="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/mcphub-bearer"
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
    memory = mkMcpHubServer "memory";
    todoist = mkMcpHubServer "todoist";
    github = mkMcpHubServer "github";
    context7 = mkMcpHubServer "context7";
    google-workspace = mkMcpHubServer "google-workspace";
    obsidian = mkMcpHubServer "obsidian";
    posthog = {
      command = "${pkgs.writeShellScript "posthog-mcp" ''
        POSTHOG_KEY="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/agenix/posthog"
        exec ${claudeNodejs}/bin/npx -y mcp-remote@latest \
          https://mcp.posthog.com/mcp \
          --header "x-posthog-api-key:$(cat "$POSTHOG_KEY")"
      ''}";
      args = [ ];
    };
    chrome-devtools = mkMcpHubServer "chrome-devtools";
    neovim = mkMcpHubServer "neovim";
    shadcn = mkMcpHubServer "shadcn";
    tailscale = mkMcpHubServer "tailscale";
    mcphub-smart = mkMcpHubServer "$smart";
  };

in
{
  inherit mcpServers;

  packages = [
    claudeNodejs
  ];
}
