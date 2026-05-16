#!/usr/bin/env bash
# PostToolUse hook for Claude Code: lints .nix files after Edit/Write/MultiEdit.
#
# Reads the tool payload as JSON on stdin, extracts the touched file path,
# runs statix + deadnix on .nix files only, and exits with code 2 if
# findings exist — Claude Code surfaces stdout to the agent as feedback
# on the next turn so Claude sees the diagnostics without the user having
# to repeat them.
#
# runtimeInputs (jq, statix, deadnix) come from the writeShellApplication
# wrapper in default.nix.

set -euo pipefail

payload=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$payload")

case "$file" in
  *.nix) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

statix_out=$(statix check "$file" 2>&1 || true)
dead_out=$(deadnix "$file" 2>&1 || true)

if [ -n "$statix_out" ] || [ -n "$dead_out" ]; then
  # Claude Code's PostToolUse blocking-feedback path surfaces STDERR to
  # the agent on the next turn — stdout from a hook is dropped. Write
  # all diagnostics to >&2 so the linter findings actually reach me.
  {
    echo "Nix lint findings on $file:"
    if [ -n "$statix_out" ]; then
      echo "--- statix ---"
      echo "$statix_out"
    fi
    if [ -n "$dead_out" ]; then
      echo "--- deadnix ---"
      echo "$dead_out"
    fi
  } >&2
  exit 2
fi

exit 0
