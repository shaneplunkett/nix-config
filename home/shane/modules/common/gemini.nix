{
  config,
  pkgs,
  lib,
  ...
}:

let
  mcpServers = import ./mcp-servers.nix {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };

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
    GEMINI_SYSTEM_INSTRUCTION = config.age.secrets.gemini.path;
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
