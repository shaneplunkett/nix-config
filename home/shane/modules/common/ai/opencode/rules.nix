{ lib, config, ... }:
{

  programs.opencode.settings.instructions = [
    "~/.config/opencode/vex/core.md"
  ];

  home.activation.opencodeVexPersona = lib.hm.dag.entryAfter [ "writeBoundary" "agenixInstall" ] ''
    DEST="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/vex"
    run mkdir -p "$DEST"
    if [[ -n "''${XDG_RUNTIME_DIR:-}" && -f "${config.age.secrets.vex-core.path}" ]]; then
      run install -m 600 ${config.age.secrets.vex-core.path} "$DEST/core.md"
      run install -m 600 ${config.age.secrets.vex-compaction.path} "$DEST/compaction.md"
    else
      verboseEcho "Skipping opencodeVexPersona: agenix secrets not yet available"
    fi
  '';

}
