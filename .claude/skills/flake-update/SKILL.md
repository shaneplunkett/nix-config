---
name: flake-update
description: Read the changelogs behind a flake input bump and report what touches this config. Use when running or reviewing `nix flake update`, or bumping nixpkgs, home-manager, nix-darwin, or omniwm.
---

# Flake update

`nix flake update` only prints lock hashes. home-manager's news never
displays when it runs as a NixOS or nix-darwin module, so behaviour
changes land silently. This skill reads the upstream changelogs for the
bump window and turns them into a short **impact list** for Shane.

## 1. Pin the window

The old lock is `git show HEAD:flake.lock`; the new one is the working
`flake.lock` (run the update first if Shane asked for one). Resolve each
input through `.nodes.root.inputs.<name>` (`nixpkgs` maps to a node such
as `nixpkgs_3`) and record `locked.rev` from both locks. Inputs whose rev
did not move drop out.

Changelogs are read for nixpkgs, home-manager, nix-darwin and omniwm.
Every other moved input is covered by the builds in step 2 alone; name
them in the report so that limit is visible.

Fetch both sides of each changelog input locally:
`nix flake prefetch --json github:<owner>/<repo>/<rev> | jq -r .storePath`.
Diff the local trees. GitHub's compare API stops at 300 files and drops
the rest silently.

Done when each changelog input that moved has an old and a new store
path.

## 2. Read the sources

Diff old against new; added entries are the window. Entry dates are not:
home-manager backdates news, so filtering by `time` misses most of it.

- **home-manager**: `diff -r` the `modules/misc/news/` trees. Read every
  added entry, honouring its `condition` (e.g. darwin-only).
- **nix-darwin**: added lines in `CHANGELOG`.
- **nixpkgs**: added lines in `doc/release-notes/rl-*.section.md` and
  `nixos/doc/manual/release-notes/rl-*.section.md`.
- **omniwm**: the diff of `nix/`, `scripts/` and `settings-defaults.toml`.
  It is a one-person flake whose activation script runs on every switch
  and whose bumps land on main without review, so audit the diff rather
  than summarise it: new commands, network access, writes outside
  `~/.config/omniwm/`, or a package URL off `github.com/OmniNull/OmniWM`.

Then build every host (`nh os build . -H desktop`,
`scripts/darwin-build.sh build <host>` for each darwin host) and keep the
`evaluation warning:` lines. A warning belongs to the bump only if the
old lock evaluates clean (`git stash` or a worktree at `HEAD`). Trace a
new one to its source with
`--option abort-on-warn true --show-trace`.

Done when every added entry has been read and every warning is marked
new or pre-existing.

## 3. Triage

Classify each item as **hits**, **opt-in**, or **miss**:

- **Hits**: names an option, module, or package this repo sets or
  installs. Grep the repo for it; a hit needs the file that uses it.
- **Opt-in**: a new default gated on `home.stateVersion` or
  `system.stateVersion`. This repo's state versions are old, so these
  defaults never arrive on their own (home-manager's `copyApps` sat
  unnoticed this way). Read the current values from the host configs
  before judging.
- **Miss**: everything else.

Done when every item from step 2 has a class.

## 4. Report

Give Shane the hits and opt-ins only: one line each saying what changed,
where it touches the config, and the suggested move. Name the count of
misses in one closing line. When nothing hits, say so in one sentence.
Make no config changes until she picks what to act on.
