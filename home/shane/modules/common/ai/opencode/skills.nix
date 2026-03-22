{ lib, ... }:
{

  home.activation.opencodeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SKILLS_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills"
    run mkdir -p "$SKILLS_DIR"

    # Clean existing skill symlinks (managed by this activation)
    run find "$SKILLS_DIR" -maxdepth 1 -type l -delete 2>/dev/null || true

    # Symlink personal skills
    for skill in "$HOME/ai-skills/personal"/*/; do
      [ -d "$skill" ] || continue
      name=$(basename "$skill")
      run ln -sfn "$skill" "$SKILLS_DIR/$name"
    done

    # Symlink work skills
    for skill in "$HOME/ai-skills/work"/*/; do
      [ -d "$skill" ] || continue
      name=$(basename "$skill")
      run ln -sfn "$skill" "$SKILLS_DIR/$name"
    done
  '';

}
