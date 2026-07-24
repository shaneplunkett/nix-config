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

      claudeAgent = {
        driver = "claudeAgent";
        enabled = true;
        config = {
          enabled = true;
          binaryPath = lib.getExe config.programs.claude-code.finalPackage;
          homePath = "${homeDirectory}/${config.vex.ai.claude.configDir}";
        };
      };
    };
  };
}
