{
  config,
  pkgs,
  lib,
  ...
}:

let
  mcpServers = import ../mcp {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

  colours = import ../../theme/colours.nix;

  catppuccinMocha = {
    name = "Catppuccin Mocha";
    type = "custom";
    Background = "#${colours.base}";
    Foreground = "#${colours.text}";
    LightBlue = "#${colours.sky}";
    AccentBlue = "#${colours.blue}";
    AccentPurple = "#${colours.mauve}";
    AccentCyan = "#${colours.teal}";
    AccentGreen = "#${colours.green}";
    AccentYellow = "#${colours.yellow}";
    AccentRed = "#${colours.red}";
    Comment = "#${colours.overlay2}";
    Gray = "#${colours.overlay1}";
    DiffAdded = "#546d5c";
    DiffRemoved = "#734a5f";
    GradientColors = [
      "#${colours.blue}"
      "#${colours.mauve}"
      "#${colours.red}"
    ];
  };
in
{

  # Copy Catppuccin Mocha theme file (not symlink) for Gemini CLI compatibility
  # Gemini CLI won't load themes that resolve outside home directory
  home.activation.copyGeminiTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.gemini/themes
        $DRY_RUN_CMD rm -f $HOME/.gemini/themes/catppuccin-mocha.json
        $DRY_RUN_CMD cat > $HOME/.gemini/themes/catppuccin-mocha.json <<'EOF'
    ${builtins.toJSON catppuccinMocha}
    EOF
        $DRY_RUN_CMD chmod 644 $HOME/.gemini/themes/catppuccin-mocha.json
  '';
  home.sessionVariables = {
    GOOGLE_CLOUD_PROJECT = "autograb-dev";
    GEMINI_SYSTEM_MD = config.age.secrets.gemini.path;
  };
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
