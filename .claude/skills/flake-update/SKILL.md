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
as `nixpkgs_3`), then record `locked.rev` and `locked.lastModified` from
both locks. The window is old `lastModified` (exclusive) to new
(inclusive). Inputs whose rev did not move drop out.

Done when every moved input listed below has an old and new rev.

## 2. Read the sources

- **home-manager**: `modules/misc/news/YYYY/MM/*.nix` in the new source.
  Read entries whose `time` falls in the window, honouring each
  `condition` (e.g. darwin-only).
- **nix-darwin**: `CHANGELOG` at the repo root. Read dated entries in the
  window.
- **nixpkgs**: `doc/release-notes/rl-*.section.md` and
  `nixos/doc/manual/release-notes/rl-*.section.md`. Read lines added
  between the old and new rev.
- **omniwm**: `gh api repos/mst-mkt/omniwm.nix/compare/<old>...<new>`.
  Read changes under `nix/`, `scripts/`, and `settings-defaults.toml`.

New sources are in the store after the update:
`nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.<name>.outPath'`.
Fetch an old file with
`gh api -H "Accept: application/vnd.github.raw" "repos/<owner>/<repo>/contents/<path>?ref=<old-rev>"`
and diff it against the new one.

omniwm is a one-person flake whose activation script runs on every
switch and whose bumps land on main without review. Audit its diff, not
just summarise it: new commands, network access, writes outside
`~/.config/omniwm/`, or a package URL off `github.com/OmniNull/OmniWM`.

Then build every host (`nh os build . -H desktop`,
`scripts/darwin-build.sh build <host>` for each darwin host) and keep the
`evaluation warning:` lines. Deprecations surface there first.

Done when every source for every moved input has been read in full for
the window.

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
