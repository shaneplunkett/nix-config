#!/usr/bin/env bash
# PreToolUse hook: checks if the command's binary is on PATH.
# If not, blocks the call and tells Claude to use nix-shell.

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# Strip leading env var assignments (FOO=bar cmd ...) and sudo/nix-shell wrappers
CLEAN="$COMMAND"
# Already wrapped in nix-shell — let it through
if echo "$CLEAN" | grep -qP '^\s*nix-shell\b'; then exit 0; fi
# Strip leading env assignments
CLEAN=$(echo "$CLEAN" | sed 's/^[[:space:]]*\([A-Za-z_][A-Za-z_0-9]*=[^[:space:]]*[[:space:]]*\)*//')
# Strip sudo
CLEAN=$(echo "$CLEAN" | sed 's/^[[:space:]]*sudo[[:space:]]*//')

# Extract the first token (the binary) from the first line only
BIN=$(echo "$CLEAN" | head -1 | awk '{print $1}')

[ -z "$BIN" ] && exit 0

# Skip shell builtins and common patterns that aren't real binaries
case "$BIN" in
  cd|echo|printf|export|set|unset|source|.|exec|eval|test|\[|if|then|else|fi|for|while|do|done|case|esac|true|false|read|shift|return|exit|trap|wait|kill|type|hash|command|builtin|declare|local|readonly|typeset|let|ulimit|umask|alias|unalias|enable|help|logout|dirs|pushd|popd|shopt|complete|compgen|compopt|mapfile|readarray|coproc|select|until|function|time|{|}|!)
    exit 0
    ;;
esac

# Skip paths (./foo, /usr/bin/foo) — if they specified a path they know what they're doing
case "$BIN" in
  ./*|/*) exit 0 ;;
esac

# Check if the binary is on PATH
if ! command -v "$BIN" &>/dev/null; then
  echo "Command '$BIN' is not on PATH. Use nix-shell -p <package> --run '...' to make it available, or check the package name." >&2
  exit 2
fi

exit 0
