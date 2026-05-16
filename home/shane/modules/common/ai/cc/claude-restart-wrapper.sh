#!/bin/sh
# Vendored & adapted from yacb2/claude-restart (MIT) — restart Claude Code
# in-place without burning tokens.
#
# Flow: type `restart` at the prompt → UserPromptSubmit hook intercepts BEFORE
# the model runs → touches restart-flag-<pid> + kill -TERM $PPID (this wrapper)
# → this wrapper's loop sees the flag → respawns claude with --resume <session-id>.
#
# Differences from upstream:
#   - Handoff machinery dropped (single-tool install, restart-only)
#   - No PATH-walk for the binary — `command -v claude` from /bin/sh resolves
#     the home-manager-wrapped claude cleanly (the fish function `claude` only
#     shadows in fish, not in /bin/sh, so no recursion risk)
#   - English-only output
#   - POSIX-compatible (sh / bash / dash / zsh)

set -u

CLAUDE_TMP_DIR="${HOME}/.claude/tmp"
WRAPPER_ID=$$
RESTART_FLAG="${CLAUDE_TMP_DIR}/restart-flag-${WRAPPER_ID}"
SESSION_FILE="${CLAUDE_TMP_DIR}/session-id-${WRAPPER_ID}"

# Exposed to hooks via env. SessionStart writes to session-id-<id>;
# UserPromptSubmit touches restart-flag-<id>. Per-PID scope means multiple
# terminals never collide on each other's flags.
export CLAUDE_RESTART_ID="$WRAPPER_ID"

mkdir -p "$CLAUDE_TMP_DIR"

# Resolve claude binary once at startup. Wrapper script runs in /bin/sh so
# fish function shadowing doesn't apply — `command -v claude` finds the
# home-manager-wrapped binary on PATH.
CLAUDE_BIN=$(command -v claude)
if [ -z "$CLAUDE_BIN" ]; then
  echo "claude-restart: claude binary not found on PATH" >&2
  exit 1
fi

cleanup() {
  rm -f "$RESTART_FLAG" "$SESSION_FILE"
}
trap cleanup EXIT INT TERM

# Clear stale state in case this PID was previously used by another process
rm -f "$RESTART_FLAG" "$SESSION_FILE"

# First run — pass through original args (so `claude --resume`, `claude -p ...`,
# `CLAUDE_CONFIG_DIR=$HOME/.claude-work claude` etc. all still work)
"$CLAUDE_BIN" "$@"

# Restart loop — re-spawns claude as long as the flag is set after each exit
while [ -f "$RESTART_FLAG" ]; do
  rm -f "$RESTART_FLAG"

  SESSION_ID=""
  if [ -f "$SESSION_FILE" ]; then
    SESSION_ID=$(cat "$SESSION_FILE")
  fi

  if [ -n "$SESSION_ID" ]; then
    # Warn on huge sessions — Claude Code compaction is in-memory only and
    # is not persisted to disk, so resume reloads the full JSONL and may
    # re-trigger compaction.
    SESSION_JSONL=$(find "$HOME/.claude/projects" -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
    if [ -n "$SESSION_JSONL" ]; then
      FILE_SIZE=$(wc -c < "$SESSION_JSONL" | tr -d ' ')
      SIZE_MB=$((FILE_SIZE / 1048576))
      if [ "$SIZE_MB" -ge 2 ]; then
        echo
        echo "  ⚠ Large session detected (${SIZE_MB}MB) — reload may re-trigger compaction."
      fi
    fi
    echo
    echo "  ↻ Restarting Claude Code — resuming session ${SESSION_ID%%-*}…"
    echo
    "$CLAUDE_BIN" --resume "$SESSION_ID"
    RESUME_EXIT=$?
    if [ "$RESUME_EXIT" -ne 0 ] && [ ! -f "$RESTART_FLAG" ]; then
      echo
      echo "  ⚠ Resume failed — starting fresh session…"
      echo
      "$CLAUDE_BIN" "$@"
    fi
  else
    echo
    echo "  ↻ Restarting Claude Code — no session ID captured, starting fresh…"
    echo
    "$CLAUDE_BIN" "$@"
  fi
done
