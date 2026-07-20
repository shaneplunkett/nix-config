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
          homePath = "${homeDirectory}/.codex";
        };
      };

      claudeAgent = {
        driver = "claudeAgent";
        enabled = true;
        config = {
          enabled = true;
          # Use the Home Manager profile wrapper so Claude receives
          # CLAUDE_CONFIG_DIR=$HOME/.claude-work and its work OAuth session.
          binaryPath = "${config.home.profileDirectory}/bin/claude-work";
          # Claude's setting is a HOME override, not the config directory.
          homePath = homeDirectory;
        };
      };
    };
  };
}
