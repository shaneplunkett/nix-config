#!/bin/sh
# PostToolUse hook for Claude Code and Codex: formats each .nix file an agent
# just edited, then hands back any statix or deadnix findings so they're fixed
# in the same turn rather than at the Stop hook. Claude Code sends
# tool_input.file_path; Codex sends the apply_patch text instead.
set -u
export NO_COLOR=1 # plain text for the agent, not terminal colours

input="$(cat)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
[ -z "$cwd" ] || cd "$cwd" || exit 0

report="$(mktemp)"
printf '%s' "$input" | jq -r '
  .tool_input as $t
  | ($t | objects | .file_path // empty),
    (($t | if type == "object" then (.command // .patch // "") else . end)
      | strings | split("\n")[]
      | capture("^\\*\\*\\* (Add File|Update File|Move to): (?<path>.+)$")? | .path)
' | grep '\.nix$' | sort -u | while IFS= read -r file; do
  [ -f "$file" ] || continue
  nixfmt "$file" >/dev/null 2>&1
  out="$( { statix check "$file"; deadnix "$file"; } 2>&1 )"
  [ -n "$out" ] && printf 'Nix lint findings in %s:\n%s\n\n' "$file" "$out"
done >"$report"

findings="$(cat "$report")"
rm -f "$report"
[ -n "$findings" ] || exit 0

jq -n --arg reason "$findings" '{
  decision: "block",
  reason: $reason,
  hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: $reason }
}'
