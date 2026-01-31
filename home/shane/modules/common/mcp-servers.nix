{
  pkgs,
  config,
  homeDirectory,
}:
let
  claudeNodejs = pkgs.nodejs;

  mcp-language-server = pkgs.buildGoModule {
    pname = "mcp-language-server";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "isaacphi";
      repo = "mcp-language-server";
      rev = "e4395849a52e18555361abab60a060802c06bf50";
      sha256 = "sha256-INyzT/8UyJfg1PW5+PqZkIy/MZrDYykql0rD2Sl97Gg=";
    };
    vendorHash = "sha256-WcYKtM8r9xALx68VvgRabMPq8XnubhTj6NAdtmaPa+g=";
    subPackages = [ "." ];
    doCheck = false;
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

    todoist =
      let
        todoist-wrapper = pkgs.writeShellScript "todoist-mcp-wrapper" ''
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          export API_KEY=$(cat $XDG_RUNTIME_DIR/agenix/todoist)
          exec ${claudeNodejs}/bin/npx -y todoist-mcp
        '';
      in
      {
        command = "${todoist-wrapper}";
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

    obsidian = {
      command = "${claudeNodejs}/bin/npx";
      args = [
        "-y"
        "@mauricio.wolff/mcp-obsidian@latest"
        "${homeDirectory}/Prime"
      ];
    };
  };
in
{
  inherit mcpServers;

  packages = [
    mcp-language-server
    claudeNodejs
  ];
}
