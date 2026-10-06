#!/usr/bin/env bash
# Evaluate, build or switch any host from any machine.
#
# Syncs this working tree, as git sees it (no commit or push needed), into a
# scratch checkout on the machine that does the work and runs nh there. eval
# and build go to an always-on builder for the host's platform; switch runs
# on the host itself. When that machine is this one, nh runs here directly.
# At a terminal you get nh's live build tree; an agent (no TTY) gets plain
# text. The exit code is the remote's.
#
#   scripts/remote.sh [eval|build|switch] [host]   # defaults: build mini-server
set -euo pipefail

mode="${1:-build}"
host="${2:-mini-server}"
scratch=".cache/nix-config-build" # under $HOME on the remote

usage() {
  echo "usage: $0 [eval|build|switch] [desktop|mini-server|mini|Shanes-MacBook-Pro|mbp]" >&2
  exit 64
}

case "$mode" in
  eval | build | switch) ;;
  *) usage ;;
esac

# The SSH aliases work as host names too.
case "$host" in
  mini) host=mini-server ;;
  mbp) host=Shanes-MacBook-Pro ;;
esac

case "$host" in
  desktop) platform=os builder=desktop ;;
  mini-server | Shanes-MacBook-Pro) platform=darwin builder=mini-server ;;
  *) usage ;;
esac

if [ "$mode" = switch ]; then runner="$host"; else runner="$builder"; fi

case "$runner" in
  desktop) remote=desktop ;;
  mini-server) remote=mini ;;
  Shanes-MacBook-Pro) remote=mbp ;;
esac

case "$platform" in
  os) attr="nixosConfigurations.$host.config.system.build.toplevel.drvPath" ;;
  darwin) attr="darwinConfigurations.$host.system.drvPath" ;;
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

# nh diffs against the runner's own system, so a build of another host
# (mbp on mini-server) would print a meaningless diff. Drop it there.
diff_opts=()
if [ "$mode" = build ] && [ "$runner" != "$host" ]; then
  diff_opts=(--diff never)
fi

case "$mode" in
  # A real eval: no builds, just "does this host's config evaluate".
  eval) run="nix eval --raw .#$attr && echo && echo 'evaluates OK'" ;;
  build | switch) run="nh $platform $mode $(printf '%q ' . -H "$host" "${nom_opts[@]}" "${diff_opts[@]}")" ;;
esac

if [ "$(hostname -s)" = "$runner" ]; then
  echo "$mode $host here on $runner"
  cmd=(bash -c "$run")
else
  echo "syncing working tree to $remote:~/$scratch"
  rsync -az --delete \
    --exclude=.git --exclude=.direnv --exclude=result --exclude='result-*' \
    --filter=':- .gitignore' \
    --rsh="ssh ${ssh_opts[*]}" ./ "$remote:$scratch/"

  # The scratch dir is a git repo so the flake sees staged files. Stage
  # everything after each sync so new files count too.
  remote_script="
set -e
cd ~/$scratch
git rev-parse -q --verify HEAD >/dev/null 2>&1 || {
  git init -q
  git -c user.name=build -c user.email=build@$runner commit -q --allow-empty -m init
}
git add -A
echo \"$mode $host on \$(hostname)\"
$run
"
  cmd=(ssh "${ssh_opts[@]}" "${tty_opts[@]}" "$remote" "bash -c $(printf '%q' "$remote_script")")
fi

if [ -t 1 ]; then
  exec "${cmd[@]}"
fi
# Agent mode: plain text, colour codes stripped, remote exit code kept.
"${cmd[@]}" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
exit "${PIPESTATUS[0]}"
