{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

  mcphubWrapper = server: pkgs.writeShellScript "mcphub-${server}" ''
    AUTH="Bearer $(cat ${config.age.secrets.mcphub-bearer.path})"
    exec ${claudeNodejs}/bin/npx -y mcp-remote@latest \
      http://localhost:3000/mcp/${server} \
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
    posthog = mkMcpHubServer "posthog";
    chrome-devtools = mkMcpHubServer "chrome-devtools";
    neovim = mkMcpHubServer "neovim";
    shadcn = mkMcpHubServer "shadcn";
  };

in
{
  inherit mcpServers;

  packages = [
    claudeNodejs
  ];
}
