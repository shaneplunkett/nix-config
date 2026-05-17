#!/usr/bin/env bash
# Generic hook helper for codex: emit a file's contents as additionalContext
# wrapped in the hook-specific JSON output schema codex expects.
#
# Usage: codex-emit-context <event-name> <markdown-file>
#
# Codex parses hook stdout as JSON conforming to <event>.command.output schema.
# Raw stdout (e.g. plain `cat foo.md`) is silently ignored. To inject context
# we have to wrap it as:
#
#   { "hookSpecificOutput": {
#       "hookEventName": "<event>",
#       "additionalContext": "<text>"
#     } }
#
# The event name is camelCase per the wire schema rename_all rule.
#
# runtimeInputs (jq) come from the writeShellApplication wrapper.

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: codex-emit-context <event-name> <markdown-file>" >&2
  exit 64
fi

event="$1"
file="$2"

# Drain stdin — codex sends the event payload, we don't read it for this helper.
cat > /dev/null

[ -f "$file" ] || { echo "codex-emit-context: file not found: $file" >&2; exit 1; }

content=$(cat "$file")

jq -n \
  --arg event "$event" \
  --arg ctx "$content" \
  '{ hookSpecificOutput: { hookEventName: $event, additionalContext: $ctx } }'
