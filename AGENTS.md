# nix-config

## Build

| Host | System | Command |
|---|---|---|
| `desktop` | x86_64-linux | `nh os switch . -H desktop` |
| `Shanes-MacBook-Pro` | aarch64-darwin | `nh darwin switch . -H Shanes-MacBook-Pro` |
| `Shanes-Work-MacBook-Pro` | aarch64-darwin | `nh darwin switch . -H Shanes-Work-MacBook-Pro` |
| `hetzvps` | aarch64-linux | deploy-rs (server, not local) |

Build only (no activation): `nh {os,darwin} build . -H <host>`. Apply changes with `nrs`.

Codex can run `nh os switch . -H desktop` directly; do not assume a sudo prompt
means Shane must do it manually. Passwordless switching is configured in
`modules/nixos/user.nix`. If `nh` suddenly asks for a password, inspect the
actual sudo command it is running: the allowed shapes include
`switch-to-configuration {test,boot,switch}` and `sudo env ...`, including both
`/run/current-system/sw/bin/env` and Nix store `coreutils` `env` paths.

## Research — don't rely on training data alone

- **Library shapes, derivation patterns, home-manager / nixpkgs options** → Context7 via MCPHub. Search: `mcp__claude_ai_MCPHub__search_tools` for "context7", then `call_tool` to fetch live docs.
- **Current state of the world, unknown tools, comparisons** → tavily (`tvly search "..."`, or `tvly research "..."` for deeper synthesis with citations).
- Default to checking. Nix QoL tools (`nh`, `nurl`, `nix-init`, `nix-locate`, `manix`, `comma-with-db`) are 2025+; training data is stale.

## Nix idioms — DEFAULT

**Nix > bash.** Shell only when the shape is genuinely shell (mutating external state, runtime iter outside the store, JSON merges preserving runtime-only fields).

Prefer:
- `home.file` + `mkOutOfStoreSymlink` over activation scripts
- `writeShellApplication { name; runtimeInputs; text }` over `writeShellScriptBin`
- `lib.mapAttrs'` + `nameValuePair` over copy-paste blocks
- `stdenv.mkDerivation` over activation-time jq merges
- Verify shape via Context7 (home-manager / nixpkgs source) before committing
- Collapse repeated keys via nested attrset (statix W20)

## Project packages

Fetched or built third-party packages belong in `pkgs/`, not inline inside
Home Manager or host modules. Use one directory per package:
`pkgs/<name>/default.nix`, expose it from `pkgs/default.nix` with
`pkgs.callPackage`, then consume it as `pkgs.<name>` from modules.

Inline derivations are only for module-local glue that is genuinely tied to the
module, such as small `writeShellApplication` wrappers. Keep runtime wrappers
near the module when they mainly inject secrets or compose commands, but move
the packaged tool they wrap into `pkgs/`.

For pinned packages, add `passthru.updateScript = nix-update-script { };` when
`nix-update --flake <attr>` can handle the bump cleanly. If a package needs a
manual fetcher refresh, use `nurl <url> <rev>` and keep the package addressable
from `pkgs/` anyway.

## Tooling — use THESE

| Task | Use | NOT |
|---|---|---|
| Build / switch | `nh os switch . -H <host>` | `nixos-rebuild switch --flake ...` |
| Hash + fetcher block | `nurl <url> <rev>` | `nix-prefetch-url --unpack` + `nix-hash --to-sri` |
| Find pkg by binary | `nix-locate -w -t x --minimal bin/<cmd>` | `nh search` for known bins |
| Remote pkg search | `nh search <q>` | `nix search nixpkgs` |
| Local options / docs | `manix <opt>` | grep nixpkgs |
| New package draft | `nix-init <url>` | hand-write `buildNpmPackage` / `buildGoModule` |
| Existing package bump | `nix-update --flake <attr>` | manual rev/hash replacement loops |
| Run-once no-install | `, <cmd>` | `nix shell nixpkgs#<pkg> -c` |
| Lint | `statix check .` then `statix fix .` if needed | manual review or path lists |
| Dead code | `deadnix <p>` | manual review |
| Format | `nix fmt` (nixfmt-rfc-style, tracked + staged) | manual |

For custom package pins, prefer making the package addressable from `pkgs/` with
`passthru.updateScript` when the update needs project-specific flags. Then use
`nix-update --flake <attr>` for ordinary source/hash bumps and `nurl <url> <rev>`
when you need to refresh or draft a fetcher block manually.

## Done criteria for a nix edit

1. `git add` new files — flakes ignore untracked
2. `statix check .` clean — Statix takes a single target, so run it at repo root
3. `deadnix <changed>` empty
4. `nh {os,darwin} build . -H <host>` green
5. `nix flake check` green

A PostToolUse hook auto-runs `statix` + `deadnix` after every `.nix` edit and surfaces findings as feedback. Don't ignore them.

## Secrets

**rbw (Bitwarden)** — default. CLI wrappers in `home/shane/modules/common/` shell out to `rbw get <entry>` at invocation. Rotate via Bitwarden UI → `rbw sync` → next call picks it up. No rebuild.

**agenix** — server-side only. `secrets/*.age` declared in `secrets/secrets.nix`, consumed via `config.age.secrets.<name>.path`. Currently only `hetzvps` (tailscale-authkey, restic-password, vex-* server secrets). New creds → rbw, unless a non-interactive system service can't talk to the rbw agent.

## NixVim

`home/shane/modules/common/nixvim/`. `default.nix` enables + imports. `plugins/default.nix` aggregates. Each plugin = own file `plugins/<name>.nix`.

Darwin-only packages (`xcbeautify`, `swiftformat`, `swiftlint`, `sourcekit`) → guard with `lib.mkIf pkgs.stdenv.isDarwin` or `lib.optionals pkgs.stdenv.isDarwin`.

## AI modules

Base AI tooling lives in `home/shane/modules/common/ai/` and is imported by
`home/shane/modules/common/default.nix`.

`home/shane/modules/common/ai/`:
- `mcp/` — canonical `programs.mcp.servers` registry shared by Claude Code and Codex. Prefer pinned Nix packages for server binaries; runtime wrappers are only for secrets.
- `cc/` — Claude Code. Settings, hooks, theme, plugins via `programs.claude-code` module. Private values (work URLs, work email) come from `inputs.nix-config-private`.
- `codex/` — Codex CLI. Settings, hooks, skills, rules, and Vex AGENTS.md context via `programs.codex`.

Claude Code uses tweakcc's `claudeMdAltNames` patch, with `AGENTS.md` as the first fallback when no project `CLAUDE.md` exists. Keep this root file as the shared project rules file unless there is a specific reason to split harness behaviour.

## Git

Flakes only see git-tracked files. `git add` new files BEFORE building. Untracked → invisible to the build → confusing errors.

Keep this repo clean for Shane. When you notice pre-existing local changes,
staged files, or local commits outside the current task, do not ignore them until
the end of the session. Inspect them, separate them from your own work, and
quietly carry coherent finished work through the normal hygiene path: format,
lint/dead-code checks, host build when relevant, commit, and push. Never discard,
reset, or overwrite Shane's changes unless she explicitly asks; if a change is
ambiguous or unsafe to ship, leave it intact and call out exactly what needs her
decision.
