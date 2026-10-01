#!/usr/bin/env bash
# Evaluate or test-build a darwin host on mini-server from any machine.
#
# Syncs this working tree, as git sees it (no commit or push needed), into a
# scratch checkout on the mini and runs nh there. At a terminal you get nh's
# live build tree; an agent (no TTY) gets plain text. The exit code is the
# remote build's.
#
#   scripts/darwin-build.sh [eval|build] [host]   # defaults: build mini-server
set -euo pipefail

mode="${1:-build}"
host="${2:-mini-server}"
remote="mini"
scratch=".cache/nix-config-build" # under $HOME on the mini

case "$mode" in
  eval | build) ;;
  *)
    echo "usage: $0 [eval|build] [host]" >&2
    exit 64
    ;;
esac

cd "$(git rev-parse --show-toplevel)"

# `ssh mini` forces a login fish shell; one-shot commands need it off.
ssh_opts=(-o RemoteCommand=none)
if [ -t 1 ]; then
  tty_opts=(-t)
  nom_opts=()
else
  tty_opts=(-T)
  nom_opts=(--no-nom)
fi

echo "syncing working tree to $remote:~/$scratch"
rsync -az --delete \
  --exclude=.git --exclude=.direnv --exclude=result --exclude='result-*' \
  --filter=':- .gitignore' \
  --rsh="ssh ${ssh_opts[*]}" ./ "$remote:$scratch/"

case "$mode" in
  # A real eval: no builds, just "does this host's config evaluate".
  eval) remote_cmd="nix eval --raw ~/$scratch#darwinConfigurations.$host.system.drvPath && echo && echo 'evaluates OK'" ;;
  build) remote_cmd="nh darwin build $(printf '%q ' "$scratch" -H "$host" "${nom_opts[@]}")" ;;
esac

# The scratch dir is a git repo so the flake sees staged files. Stage
# everything after each sync so new files count too.
remote_script="
set -e
cd ~/$scratch
git rev-parse -q --verify HEAD >/dev/null 2>&1 || {
  git init -q
  git -c user.name=build -c user.email=build@mini commit -q --allow-empty -m init
}
git add -A
cd ~
echo \"$mode $host on \$(hostname)\"
$remote_cmd
"
if [ -t 1 ]; then
  exec ssh "${ssh_opts[@]}" "${tty_opts[@]}" "$remote" "bash -c $(printf '%q' "$remote_script")"
fi
# Agent mode: plain text, colour codes stripped, remote exit code kept.
# shellcheck disable=SC2029 # the script is meant to expand here, then run there
ssh "${ssh_opts[@]}" "${tty_opts[@]}" "$remote" "bash -c $(printf '%q' "$remote_script")" 2>&1 \
  | sed 's/\x1b\[[0-9;]*m//g'
exit "${PIPESTATUS[0]}"
