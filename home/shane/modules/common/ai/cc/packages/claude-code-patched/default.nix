# claude-code-patched — pkgs.claude-code with tweakcc-fixed applied at build
# time. Pairs with skrabe/lobotomized-claude-code for slimmer system prompts
# and per-turn injections tuned for Opus 4.7.
#
# The patch lives in preFixup so it runs AFTER installPhase (which puts the
# original Bun binary at $out/bin/.claude-wrapped) but BEFORE autoPatchelfHook
# in fixupPhase: LIEF can't parse the autoPatchelf'd ELF because the added
# LOAD segment for the longer Nix-store interpreter path confuses its program-
# header walk and segfaults during native-binary extraction.
#
# Adapted from github.com/typedrat/nix-config/packages/claude-code-patched (MIT).
{
  lib,
  fetchFromGitHub,
  claude-code,
  tweakcc-fixed,
  jq,
  nix-update-script,
  # User-supplied tweakcc config — tracked alongside this package so tweaks
  # are reproducible across hosts. Edit ./config.json to change knobs.
  tweakccConfig ? ./config.json,
}:
let
  # skrabe/lobotomized-claude-code: slim, less-CAPS-heavy rewrites of Claude
  # Code's system prompts and per-turn injections tuned for Opus 4.7. Not
  # actually lobotomy — strips over-the-top prompt engineering and shrinks
  # the always-injected fragments. Bump rev + hash via nurl on update.
  promptOverrides = fetchFromGitHub {
    owner = "skrabe";
    repo = "lobotomized-claude-code";
    rev = "4bb5dbb81d743107da5abadd026691c9d226bc02";
    hash = "sha256-uU8wRE3NwK9LFu8UG2kkwAU9/xM/0IbRbAacRlYRTXc=";
  };
in
claude-code.overrideAttrs (prev: {
  pname = "claude-code-patched";

  nativeBuildInputs = prev.nativeBuildInputs ++ [
    tweakcc-fixed
    jq
  ];

  preFixup =
    (prev.preFixup or "")
    + ''
      # Stage tweakcc's expected HOME / config layout in the sandbox.
      export TWEAKCC_CONFIG_DIR="$TMPDIR/tweakcc"
      export HOME="$TMPDIR/home"
      mkdir -p "$TWEAKCC_CONFIG_DIR" "$HOME"

      install -m 0644 ${tweakccConfig} "$TWEAKCC_CONFIG_DIR/config.json"
      # tweakcc seeds defaults into system-prompts/ and system-reminders/
      # on first --apply, so they must be writable — symlinks back to the
      # immutable prompt-overrides source are insufficient.
      cp -RL ${promptOverrides}/system-prompts  "$TWEAKCC_CONFIG_DIR/system-prompts"
      cp -RL ${promptOverrides}/system-reminders "$TWEAKCC_CONFIG_DIR/system-reminders"
      chmod -R u+w "$TWEAKCC_CONFIG_DIR/system-prompts" "$TWEAKCC_CONFIG_DIR/system-reminders"

      # Scrub the captured config's installation pointer and applied flag
      # so tweakcc targets the binary in *this* derivation and actually
      # re-runs the patches.
      jq 'del(.ccInstallationPath, .ccInstallationDir) | .changesApplied = false' \
        "$TWEAKCC_CONFIG_DIR/config.json" > "$TWEAKCC_CONFIG_DIR/config.json.new"
      mv "$TWEAKCC_CONFIG_DIR/config.json.new" "$TWEAKCC_CONFIG_DIR/config.json"

      # wrapProgram already moved the original binary to .claude-wrapped in
      # installPhase. Patch that one — the outer `claude` is the
      # makeBinaryWrapper shim and gets autoPatchelf'd separately.
      export TWEAKCC_CC_INSTALLATION_PATH="$out/bin/.claude-wrapped"
      ${lib.getExe tweakcc-fixed} --apply
    '';

  passthru = (prev.passthru or { }) // {
    unpatched = claude-code;
    promptOverridesSrc = promptOverrides;
    updateScript = nix-update-script { attrPath = "claude-code"; };
  };

  meta = prev.meta // {
    description = "Claude Code with skrabe/lobotomized-claude-code system-prompt overrides applied via tweakcc-fixed";
  };
})
