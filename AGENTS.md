# nix-config

## Build

`scripts/remote.sh [eval|build|switch] [host]` evaluates, builds or
switches any host from any machine. It syncs the working tree (no commit
needed) to the machine doing the work and runs nh there, streaming nh's
output and exit code back. eval and build go to an always-on builder
(darwin can't build on the desktop, so darwin goes to `mini-server`);
switch runs on the host itself, in place when that's this machine.

| Host | System | Short name |
|---|---|---|
| `desktop` | x86_64-linux | `desktop` |
| `Shanes-MacBook-Pro` | aarch64-darwin | `mbp` |
| `mini-server` | aarch64-darwin | `mini` |

Switching is passwordless on every host: `modules/nixos/user.nix` and
`modules/darwin/base/user.nix` allow exactly the commands nh elevates. If
`nh` prompts, inspect the sudo command it ran rather than assuming Shane
has to do it. Home Manager is part of the host switch; standalone
activations such as `home-manager switch` or `./result/activate` run
side-effect hooks, so use them only when Shane asks for that exact
operation.

The dev shell (`lib/devshell.nix`, loaded by direnv) carries the repo's
tools and wraps remote.sh as `switch`, `build` and `evaluate` (host
defaults to this machine) plus `check`. `nrs` switches the current host.

A new host needs a row in remote.sh's host table and its
`/etc/ssh/ssh_host_ed25519_key.pub` in `modules/common/ssh-known-hosts.nix`.
remote.sh's SSH has no terminal to accept an unknown host key, so a
missing key fails the connection.

## Checks

`scripts/check.sh` (nixfmt, statix, deadnix) is the one gate. Hooks run it
for you in Claude Code and Codex: each `.nix` edit is formatted and linted
straight after, the Stop hook runs it before you finish, and pre-commit
runs it on every commit. Fix what it reports. If a rule is wrong for the
case, say so and propose a change to `statix.toml`.

What hooks can't do: `scripts/remote.sh build <host>` must be green for
every host the change touches before a task is done. `git add` new files first; flakes ignore untracked
files, and the resulting errors are confusing.

## Research

Nix QoL tools (`nh`, `nurl`, `nix-init`, `nix-update`, `manix`, comma) are
2025+, so training data is stale. Check Context7 (resolve the library,
then query) for home-manager, nixpkgs, and nix-darwin option shapes before
committing to one. Use tavily for the current state of the world.

## Nix idioms

Nix over bash: shell only when the shape is genuinely shell (mutating
external state, runtime iteration outside the store).

- `home.file` + `mkOutOfStoreSymlink` over activation scripts
- `writeShellApplication` over `writeShellScriptBin`
- `lib.mapAttrs'` + `nameValuePair` over copy-paste blocks
- `stdenv.mkDerivation` over activation-time merges

| Task | Use |
|---|---|
| Hash + fetcher block | `nurl <url> <rev>` |
| Find pkg by binary | `nix-locate -w -t x --minimal bin/<cmd>` |
| Remote pkg search | `nh search <q>` |
| Option docs | `manix <opt>` |
| New package draft | `nix-init <url>` |
| Bump a package | `nix-update --flake <attr>` |
| Run once, no install | `, <cmd>` |

## Packages

Where a new thing lives is decided by the residency rule in
`docs/environment-map.md`; read it before packaging anything or hunting
for where a CLI version comes from. In this repo, one directory per
package under `pkgs/<name>/default.nix`, exposed from `pkgs/default.nix`,
consumed as `pkgs.<name>`. Pinned packages get
`passthru.updateScript = nix-update-script { };` when `nix-update` can
handle the bump. Inline derivations are only for module-local glue such as
a small `writeShellApplication` wrapper injecting secrets.

A brand-new desktop app's icon shows as a magenta checkerboard in noctalia
until the shell restarts: `kill <quickshell pid>` then
`hyprctl eval 'hl.exec_cmd("noctalia-shell")'`.

## Secrets

rbw (Bitwarden): wrappers shell out to `rbw get <entry>` at invocation,
so rotation needs no rebuild. Values that are private but not secret go in
`nix-config-private`.

## Layout

- `home/shane/modules/common/nixvim/`: one file per plugin under
  `plugins/`. Darwin-only tools get
  `lib.optionals pkgs.stdenv.hostPlatform.isDarwin`.
- `home/shane/modules/common/ai/`: the AI harnesses. `cc/` (Claude Code),
  `codex/`, `mcp/` (shared `programs.mcp.servers` registry), `skills/`,
  and `lib.nix` with the helpers they share.
