{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

  mkGoogleWorkspace = port:
    let
      google-workspace-wrapper = pkgs.writeShellScript "google-workspace-mcp-wrapper-${toString port}" ''
        export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
        export GOOGLE_OAUTH_CLIENT_ID=$(cat ${config.age.secrets.google-oauth-client-id.path})
        export GOOGLE_OAUTH_CLIENT_SECRET=$(cat ${config.age.secrets.google-oauth-client-secret.path})
        export UV_PYTHON=${pkgs.python3}/bin/python3
        export WORKSPACE_MCP_PORT=${toString port}
        export MCP_SINGLE_USER_MODE=1
        exec ${pkgs.uv}/bin/uvx workspace-mcp
      '';
    in
    {
      command = "${google-workspace-wrapper}";
      args = [ ];
    };

  mcpServers = {
    memory = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-memory"
      ];
      env = {
        MEMORY_FILE_PATH = "${homeDirectory}/mcp-memory/memory.jsonl";
      };
    };
    shadcn = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "shadcn@latest"
        "mcp"
      ];
    };
context7 =
      let
        context7-wrapper = pkgs.writeShellScript "context7-mcp-wrapper" ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          API_KEY=$(cat ${config.age.secrets.context7.path})
          exec ${claudeNodejs}/bin/npx -y @upstash/context7-mcp --api-key "$API_KEY"
        '';
      in
      {
        command = "${context7-wrapper}";
        args = [ ];
      };

    github =
      let
        github-wrapper = pkgs.writeShellScript "github-mcp-wrapper" ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          export GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github.path})
          exec ${claudeNodejs}/bin/npx -y @modelcontextprotocol/server-github
        '';
      in
      {
        command = "${github-wrapper}";
        args = [ ];
      };

    todoist =
      let
        todoist-wrapper = pkgs.writeShellScript "todoist-mcp-wrapper" ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          export TODOIST_API_TOKEN=$(cat ${config.age.secrets.todoist.path})
          exec ${claudeNodejs}/bin/npx -y @greirson/mcp-todoist
        '';
      in
      {
        command = "${todoist-wrapper}";
        args = [ ];
      };

    posthog =
      let
        posthog-wrapper = pkgs.writeShellScript "posthog-mcp-wrapper" ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          export POSTHOG_AUTH_HEADER="Bearer $(cat ${config.age.secrets.posthog.path})"
          exec ${claudeNodejs}/bin/npx -y mcp-remote@latest https://mcp.posthog.com/mcp --header "Authorization:$POSTHOG_AUTH_HEADER"
        '';
      in
      {
        command = "${posthog-wrapper}";
        args = [ ];
      };

    google-workspace = mkGoogleWorkspace 8000;

    obsidian = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@mauricio.wolff/mcp-obsidian@latest"
        "${homeDirectory}/Prime"
      ];
    };
    desktop-commander = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@wonderwhy-er/desktop-commander@latest"
      ];
    };
    chrome-devtools = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "chrome-devtools-mcp@latest"
        "--browserUrl"
        "http://localhost:9222"
      ];
    };
  };
in
{
  inherit mcpServers mkGoogleWorkspace;

  packages = [
    claudeNodejs
  ];
}
