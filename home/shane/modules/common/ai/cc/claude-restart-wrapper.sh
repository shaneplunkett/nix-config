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

# Build LOOP_ARGS from "$@" with any user-supplied --resume / --resume=<id>
# stripped out — the restart loop below adds its own captured --resume=<id>,
# and a stray bare --resume from the original invocation (e.g. `ccr`) is
# parsed last-wins by commander and re-opens the picker.
LOOP_ARGS=()
_args=("$@")
_i=0
while [ $_i -lt ${#_args[@]} ]; do
  _arg="${_args[$_i]}"
  case "$_arg" in
    --resume=*)
      _i=$((_i + 1))
      ;;
    --resume|-r)
      _next_i=$((_i + 1))
      if [ $_next_i -lt ${#_args[@]} ]; then
        _next="${_args[$_next_i]}"
        # If the next token isn't a flag, it's the --resume value — drop both
        if [ "${_next#-}" = "$_next" ]; then
          _i=$((_i + 2))
          continue
        fi
      fi
      _i=$((_i + 1))
      ;;
    *)
      LOOP_ARGS+=("$_arg")
      _i=$((_i + 1))
      ;;
  esac
done

# Restart loop — re-spawns claude with the original flags after each exit so
# `claude --allow-dangerously-skip-permissions` (and any other CLI flags) is
# preserved across restarts. If `$@` contained `--resume <id>` the resume call
# below will duplicate it, but CC's last-wins parsing handles that fine.
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
    # Use --resume=<id> form (not "--resume <id>") so commander binds the
    # UUID to the option rather than treating it as the positional [prompt]
    # arg — the latter causes the picker to open AND the UUID to land in
    # the chat input on launch. LOOP_ARGS is $@ with --resume stripped (see
    # above) so we don't double up the flag.
    "$CLAUDE_BIN" "--resume=$SESSION_ID" "${LOOP_ARGS[@]}"
    RESUME_EXIT=$?
    if [ "$RESUME_EXIT" -ne 0 ] && [ ! -f "$RESTART_FLAG" ]; then
      echo
      echo "  ⚠ Resume failed — starting fresh session…"
      echo
      "$CLAUDE_BIN" "${LOOP_ARGS[@]}"
    fi
  else
    echo
    echo "  ↻ Restarting Claude Code — no session ID captured, starting fresh…"
    echo
    "$CLAUDE_BIN" "${LOOP_ARGS[@]}"
  fi
done
