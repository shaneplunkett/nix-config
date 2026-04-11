#!/usr/bin/env bash
# Claude Code hook: load direnv environment into session via CLAUDE_ENV_FILE.
# Triggered on SessionStart and CwdChanged so nix devShells are always available.

[ -z "$CLAUDE_ENV_FILE" ] && exit 0
command -v direnv &>/dev/null || exit 0

# Suppress direnv log noise, export bash-compatible env vars
DIRENV_OUTPUT=$(DIRENV_LOG_FORMAT= direnv export bash 2>/dev/null)

if [ -n "$DIRENV_OUTPUT" ]; then
  echo "$DIRENV_OUTPUT" >> "$CLAUDE_ENV_FILE"
fi

exit 0
