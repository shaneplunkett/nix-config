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
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.codex.package;
          homePath = "${homeDirectory}/${config.vex.ai.codex.configDir}";
        };
      };

      # Standalone sandbox instance: own CODEX_HOME so experiments (skills,
      # config, hooks) never touch the day-to-day ~/.codex, but auth.json is
      # symlinked to it so both use the same account.
      codexLab = {
        driver = "codex";
        displayName = "Codex Lab";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.codex.package;
          homePath = "${homeDirectory}/${config.vex.ai.codex.labConfigDir}";
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
