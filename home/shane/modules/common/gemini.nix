{
  config,
  pkgs,
  lib,
  ...
}:

let
  mcpServers = import ./mcp-servers.nix {
    inherit pkgs;
    homeDirectory = config.home.homeDirectory;
  };

  # Get Google Cloud project from environment or use default
  googleCloudProject =
    if builtins.getEnv "GOOGLE_CLOUD_PROJECT" != "" then
      builtins.getEnv "GOOGLE_CLOUD_PROJECT"
    else
      "autograb-dev"; # Default to your work project

  # Catppuccin Mocha theme
  catppuccinMocha = {
    name = "Catppuccin Mocha";
    type = "custom";
    Background = "#1e1e2e";
    Foreground = "#cdd6f4";
    LightBlue = "#89dceb";
    AccentBlue = "#89b4fa";
    AccentPurple = "#cba6f7";
    AccentCyan = "#94e2d5";
    AccentGreen = "#a6e3a1";
    AccentYellow = "#f9e2af";
    AccentRed = "#f38ba8";
    Comment = "#9399b2";
    Gray = "#7f849c";
    DiffAdded = "#546d5c";
    DiffRemoved = "#734a5f";
    GradientColors = [
      "#89b4fa"
      "#cba6f7"
      "#f38ba8"
    ];
  };
in
{
  # Set Google Cloud project environment variable for Gemini CLI
  home.sessionVariables = lib.mkIf (googleCloudProject != "") {
    GOOGLE_CLOUD_PROJECT = googleCloudProject;
  };

  # Generate Catppuccin Mocha theme file
  home.file.".gemini/themes/catppuccin-mocha.json".text = builtins.toJSON catppuccinMocha;

  # Generate Gemini CLI settings.json with shared MCP configuration
  home.file.".gemini/settings.json".text = builtins.toJSON {
    # General settings
    general = {
      preferredEditor = "neovim";
      vimMode = false;
      previewFeatures = true;
    };

    # UI settings with Catppuccin Mocha theme
    ui = {
      theme = "${config.home.homeDirectory}/.gemini/themes/catppuccin-mocha.json";
      showModelInfoInChat = true;
    };

    # Authentication settings for Google Workspace
    security = {
      auth = {
        selectedType = "oauth-personal";
      };
    };

    # MCP Server configuration
    mcpServers = mcpServers.mcpServers;
  };
}
