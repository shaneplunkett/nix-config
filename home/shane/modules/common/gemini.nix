{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.gemini;

  mcpServers = import ./mcp-servers.nix {
    inherit pkgs;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  options.programs.gemini = {
    enable = mkEnableOption "Gemini CLI configuration";

    googleCloudProject = mkOption {
      type = types.str;
      default = "";
      description = "Google Cloud Project ID";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration for ~/.gemini/settings.json";
    };

    mcpServers = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            command = mkOption { type = types.str; };
            args = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            env = mkOption {
              type = types.attrsOf types.str;
              default = { };
            };
          };
        }
      );
      default = mcpServers.mcpServers;
      description = "MCP Servers configuration";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf (cfg.googleCloudProject != "autograb-dev") {
      GOOGLE_CLOUD_PROJECT = cfg.googleCloudProject;
    };

    home.file.".gemini/settings.json".text = builtins.toJSON (
      cfg.settings
      // {
        mcpServers = cfg.mcpServers;
      }
    );

    # Ensure packages required by MCP servers are installed
    home.packages = mcpServers.packages;
  };
}
