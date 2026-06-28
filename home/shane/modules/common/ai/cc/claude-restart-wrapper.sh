#!/usr/bin/env bash
# Vendored & adapted from yacb2/claude-restart (MIT) — restart Claude Code
# in-place without burning tokens.
#
# Flow: type `restart` at the prompt → UserPromptSubmit hook intercepts BEFORE
# the model runs → touches restart-flag-<pid> + kill -TERM <claude-pid> →
# this wrapper's loop sees the flag → respawns claude with --continue to pick
# up the most recent session in cwd.
#
# Why --continue and not --resume=<uuid>: both --resume forms have caused
# picker-opens-instead-of-resume regressions in past CC versions; --continue
# sidesteps the entire commander.js [value] parsing question and is exactly
# the semantic we want (most-recent session in this cwd = the session being
# restarted, in 100% of single-terminal workflows).
#
# Differences from upstream:
#   - Handoff machinery dropped (single-tool install, restart-only)
#   - --continue instead of --resume=<id> for picker-free resume
#   - No PATH-walk for the binary — `command -v claude` from bash resolves
#     the home-manager-wrapped claude cleanly (the fish function `claude`
#     only shadows in fish, not in bash, so no recursion risk)

set -u

CLAUDE_TMP_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude-vex}/tmp"
WRAPPER_ID=$$
RESTART_FLAG="${CLAUDE_TMP_DIR}/restart-flag-${WRAPPER_ID}"

# Exposed to hook via env. UserPromptSubmit touches restart-flag-<id>.
# Per-PID scope means multiple terminals never collide on each other's flags.
export CLAUDE_RESTART_ID="$WRAPPER_ID"

mkdir -p "$CLAUDE_TMP_DIR"

# Resolve claude binary once at startup. Wrapper script runs in bash where
# fish function shadowing doesn't apply — `command -v claude` finds the
# home-manager-wrapped binary on PATH.
CLAUDE_BIN=$(command -v claude)
if [ -z "$CLAUDE_BIN" ]; then
  echo "claude-restart: claude binary not found on PATH" >&2
  exit 1
fi

cleanup() {
  rm -f "$RESTART_FLAG"
}
trap cleanup EXIT INT TERM

# Clear stale state in case this PID was previously used by another process
rm -f "$RESTART_FLAG"

# First run — pass through original args (so `claude --continue`, `claude -p ...`,
# `CLAUDE_CONFIG_DIR=$HOME/.claude-work claude` etc. all still work)
"$CLAUDE_BIN" "$@"

# Build LOOP_ARGS from "$@" with any user-supplied --resume / --continue
# stripped — the restart loop below adds its own --continue. A stray
# --resume from the original `ccr`-style invocation could re-open the picker
# on restart, and a stray --continue would just be redundant.
LOOP_ARGS=()
_args=("$@")
_i=0
while [ $_i -lt ${#_args[@]} ]; do
  _arg="${_args[$_i]}"
  case "$_arg" in
    --resume=*|--continue|-c)
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

# Restart loop — re-spawns claude with --continue plus the original flags
# (minus any --resume/--continue) so bypass-permissions and other CLI flags
# are preserved across restarts.
while [ -f "$RESTART_FLAG" ]; do
  rm -f "$RESTART_FLAG"

  echo
  echo "  ↻ Restarting Claude Code…"
  echo

  "$CLAUDE_BIN" --continue "${LOOP_ARGS[@]+"${LOOP_ARGS[@]}"}"
  RESUME_EXIT=$?
  if [ "$RESUME_EXIT" -ne 0 ] && [ ! -f "$RESTART_FLAG" ]; then
    echo
    echo "  ⚠ Continue failed — starting fresh session…"
    echo
    "$CLAUDE_BIN" "${LOOP_ARGS[@]+"${LOOP_ARGS[@]}"}"
  fi
done
