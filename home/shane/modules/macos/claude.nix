{ pkgs, lib, config, ... }:
let
  shared = import ../common/claude.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  home.packages = shared.packages;

  # Claude Desktop keeps ALL MCPs (no sub-agent architecture there)
  home.file."Library/Application Support/Claude/claude_desktop_config.json" = {
    text = builtins.toJSON shared.config;
  };
}
