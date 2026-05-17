#!/usr/bin/env bash
# PostToolUse hook for codex: lints .nix files after apply_patch.
#
# Codex's file editor is the `apply_patch` freeform tool — `tool_input` is the
# raw patch text rather than a structured { file_path } payload like CC. We
# extract changed paths from the apply-patch envelope ("*** Add File:" /
# "*** Update File:" / "*** Delete File: <move-from> *** Move To: <to>"
# lines), keep the .nix entries, and run statix + deadnix on each.
#
# Output protocol: codex parses hook stdout as JSON matching
# post-tool-use.command.output. Setting decision="block" + reason="..." makes
# codex surface the diagnostics back to the model as blocking feedback (the
# codex analogue of CC's exit-2-with-stderr trick).
#
# runtimeInputs (jq, statix, deadnix) come from the writeShellApplication wrapper.

set -euo pipefail

payload=$(cat)

# Depending on Codex version, apply_patch arrives either as the raw freeform
# patch string or as an object with the command text under `command`.
patch=$(
  jq -r '
    if (.tool_input | type) == "string" then
      .tool_input
    elif (.tool_input.command? | type) == "string" then
      .tool_input.command
    elif (.tool_input.patch? | type) == "string" then
      .tool_input.patch
    else
      ""
    end
  ' <<<"$payload"
)

[ -n "$patch" ] || exit 0

# Extract file paths the patch touched. The apply-patch grammar uses:
#   *** Add File: <path>
#   *** Update File: <path>
#   *** Delete File: <path>
# We treat all three the same — only lint files that still exist on disk.
mapfile -t files < <(
  printf '%s\n' "$patch" \
    | grep -E '^\*\*\* (Add|Update|Delete) File: ' \
    | sed -E 's/^\*\*\* (Add|Update|Delete) File: (.+)$/\2/' \
    | sort -u
)

findings=""

for f in "${files[@]}"; do
  case "$f" in *.nix) ;; *) continue ;; esac
  [ -f "$f" ] || continue

  statix_out=$(statix check "$f" 2>&1 || true)
  dead_out=$(deadnix "$f" 2>&1 || true)

  if [ -n "$statix_out" ] || [ -n "$dead_out" ]; then
    findings+="Nix lint findings on $f:"$'\n'
    if [ -n "$statix_out" ]; then
      findings+="--- statix ---"$'\n'"$statix_out"$'\n'
    fi
    if [ -n "$dead_out" ]; then
      findings+="--- deadnix ---"$'\n'"$dead_out"$'\n'
    fi
  fi
done

if [ -n "$findings" ]; then
  jq -n --arg reason "$findings" '{
    decision: "block",
    reason: $reason,
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $reason
    }
  }'
fi

exit 0
