{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Noctalia v5 (C++ rewrite) running side by side with the daily v4 setup.
  # NOCTALIA_CONFIG_HOME / NOCTALIA_STATE_HOME keep every v5 file out of
  # v4's ~/.config/noctalia and ~/.local/state/noctalia; the app appends
  # "/noctalia" to each, so the real dirs are
  # ~/.config/noctalia-v5/noctalia and ~/.local/state/noctalia-v5/noctalia.
  v5Package = inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default;
  configHome = "${config.xdg.configHome}/noctalia-v5";
  stateHome = "${config.xdg.stateHome}/noctalia-v5";
  tomlFormat = pkgs.formats.toml { };

  # Deliberately minimal: theme and font only. Everything else starts from
  # v5 defaults (runtime tweaks land in the isolated state dir) and gets
  # migrated into this attrset from v4's noctalia.nix piece by piece.
  settings = {
    shell.font_family = "Mononoki Nerd Font";
    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };
  };

  configToml =
    let
      raw = tomlFormat.generate "noctalia-v5-config.toml" settings;
    in
    pkgs.runCommand "noctalia-v5-config-validated" { } ''
      ${lib.getExe v5Package} config validate ${raw}
      cp ${raw} $out
    '';

  # Wrapper so both the session hook and manual CLI calls (IPC, theme,
  # validate) always hit the isolated dirs instead of v4's.
  noctaliaV5 = pkgs.writeShellApplication {
    name = "noctalia-v5";
    text = ''
      export NOCTALIA_CONFIG_HOME=${lib.escapeShellArg configHome}
      export NOCTALIA_STATE_HOME=${lib.escapeShellArg stateHome}
      exec ${lib.getExe v5Package} "$@"
    '';
  };
in
{
  home.packages = [ noctaliaV5 ];

  xdg.configFile."noctalia-v5/noctalia/config.toml".source = configToml;
}
