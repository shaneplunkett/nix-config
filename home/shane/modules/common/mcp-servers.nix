{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

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
    code-context-provider-mcp = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "code-context-provider-mcp@latest"
      ];
    };
    context7 =
      let
        context7-wrapper = pkgs.writeShellScript "context7-mcp-wrapper" ''
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
          export TODOIST_API_TOKEN=$(cat ${config.age.secrets.todoist.path})
          exec ${claudeNodejs}/bin/npx -y @greirson/mcp-todoist
        '';
      in
      {
        command = "${todoist-wrapper}";
        args = [ ];
      };

    obsidian = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@mauricio.wolff/mcp-obsidian@latest"
        "${homeDirectory}/Prime"
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
  inherit mcpServers;

  packages = [
    claudeNodejs
  ];
}
