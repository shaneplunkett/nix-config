{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  programs.t3code = {
    enable = true;
    package = pkgs.vex-code;

    userSettings.providerInstances = {
      codex = {
        driver = "codex";
        displayName = "Vex";
        accentColor = "#cba6f7";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.codex.package;
          homePath = "${homeDirectory}/${config.vex.ai.codex.configDir}";
        };
      };

      codexCode = {
        driver = "codex";
        displayName = "Code Girly";
        accentColor = "#f38ba8";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.codex.package;
          homePath = "${homeDirectory}/${config.vex.ai.codex.codeConfigDir}";
        };
      };

      # Vanilla instance: own CODEX_HOME with none of the personal context,
      # skills, hooks, or MCP servers, but auth.json is symlinked to ~/.codex
      # so both use the same account.
      codexBare = {
        driver = "codex";
        displayName = "Codex Bare";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.codex.package;
          homePath = "${homeDirectory}/${config.vex.ai.codex.bareConfigDir}";
        };
      };

      claudeAgent = {
        driver = "claudeAgent";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.claude-code.finalPackage;
          homePath = config.programs.claude-code.configDir;
        };
      };
    };
  };
}
