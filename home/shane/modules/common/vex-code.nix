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
    };
  };
}
