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
          # The work-profile wrapper published by the cc module; it sets
          # CLAUDE_CONFIG_DIR so Claude uses its work OAuth session.
          binaryPath = lib.getExe config.vex.ai.claude.workWrapper;
          # Claude's setting is a HOME override, not the config directory.
          homePath = homeDirectory;
        };
      };
    };
  };
}
