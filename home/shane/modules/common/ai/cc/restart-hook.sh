#!/bin/sh
# UserPromptSubmit hook — intercepts the literal word `restart` (trimmed,
# case-insensitive). Prints {"decision":"block"} so Claude Code drops the
# prompt without forwarding to the model, touches restart-flag-<id> for the
# wrapper to read, then SIGTERMs the parent claude-code process — its exit
# unblocks the wrapper's synchronous foreground call, and the wrapper's loop
# sees the flag and respawns claude with --continue. ZERO tokens consumed.
#
# Note: $PPID here is the claude-code bun process (claude spawns hooks
# directly as child subprocesses), NOT the wrapper. Killing claude is
# sufficient — the wrapper is the grandparent and only needs claude to
# exit for its `"$CLAUDE_BIN" "$@"` foreground call to return.

set -u

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Trim leading/trailing whitespace and lowercase
PROMPT_NORM=$(echo "$PROMPT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')

# Only intercept exact "restart"
if [ "$PROMPT_NORM" != "restart" ]; then
  exit 0
fi

# Need wrapper context — without it there's no flag-file scope and the
# wrapper can't see the restart signal.
if [ -z "${CLAUDE_RESTART_ID-}" ]; then
  echo "restart: not running inside claude-restart wrapper — open a new fish terminal" >&2
  exit 2
fi

CLAUDE_TMP_DIR="${HOME}/.claude/tmp"
RESTART_FLAG="${CLAUDE_TMP_DIR}/restart-flag-${CLAUDE_RESTART_ID}"

mkdir -p "$CLAUDE_TMP_DIR"
touch "$RESTART_FLAG"

# Order matters: print the block decision FIRST, force-close stdout so CC
# consumes the buffer, THEN signal SIGTERM. Sending the kill before the
# decision JSON risks claude exiting before reading stdout — and the block
# decision is the safety net for cases where the kill silently fails (wrong
# PPID, claude trapping TERM, etc.).
printf '{"decision":"block","reason":"Restart initiated via hook"}\n'
exec 1>&-
kill -TERM "$PPID" 2>/dev/null || true
