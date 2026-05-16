#!/bin/sh
# SessionStart hook — captures the session ID per wrapper instance so the
# restart wrapper knows what to resume.
#
# Only writes when CLAUDE_RESTART_ID is set (set by claude-restart-wrapper.sh).
# For non-wrapped invocations the hook silently no-ops.

set -u

if [ -z "${CLAUDE_RESTART_ID-}" ]; then
  exit 0
fi

CLAUDE_TMP_DIR="${HOME}/.claude/tmp"
SESSION_FILE="${CLAUDE_TMP_DIR}/session-id-${CLAUDE_RESTART_ID}"

mkdir -p "$CLAUDE_TMP_DIR"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ -n "$SESSION_ID" ]; then
  echo "$SESSION_ID" > "$SESSION_FILE"
fi
