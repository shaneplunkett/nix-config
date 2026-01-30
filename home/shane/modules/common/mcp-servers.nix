{ pkgs, homeDirectory }:
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
  };
in
{
  inherit mcpServers;

  packages = [
    mcp-language-server
    claudeNodejs
  ];
}
