{ lib, ... }:
{

  programs.opencode.settings.instructions = [
    "~/.config/opencode/vex/core.md"
  ];

  home.activation.opencodeVexPersona = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DEST="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/vex"
    run mkdir -p "$DEST"
    run install -m 600 "$HOME/ai-skills/vex/core.md" "$DEST/core.md"
    run install -m 600 "$HOME/ai-skills/vex/hooks/compaction.md" "$DEST/compaction.md"
  '';

}
