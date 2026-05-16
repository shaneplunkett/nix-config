#!/bin/sh
# UserPromptSubmit hook — intercepts the literal word `restart` (trimmed,
# case-insensitive). Touches restart-flag-<id>, signals SIGTERM to the
# wrapper ($PPID = the claude-restart-wrapper.sh process), and outputs
# `{"decision":"block"}` so Claude Code never forwards the prompt to the
# model. ZERO tokens consumed.

set -u

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Trim leading/trailing whitespace and lowercase
PROMPT_NORM=$(echo "$PROMPT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')

# Only intercept exact "restart"
if [ "$PROMPT_NORM" != "restart" ]; then
  exit 0
fi

# Need wrapper context — without it there's no flag-file scope, no $PPID
# pointing at the right wrapper, and the kill would target the wrong process.
if [ -z "${CLAUDE_RESTART_ID-}" ]; then
  echo "restart: not running inside claude-restart wrapper — open a new fish terminal" >&2
  exit 2
fi

CLAUDE_TMP_DIR="${HOME}/.claude/tmp"
RESTART_FLAG="${CLAUDE_TMP_DIR}/restart-flag-${CLAUDE_RESTART_ID}"

mkdir -p "$CLAUDE_TMP_DIR"
touch "$RESTART_FLAG"
kill -TERM "$PPID" 2>/dev/null || true

# Tell Claude Code to drop this prompt entirely — model is never woken
printf '{"decision":"block","reason":"Restart initiated via hook"}'
