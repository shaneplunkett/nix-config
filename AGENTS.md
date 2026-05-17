# nix-config

## Build

| Host | System | Command |
|---|---|---|
| `desktop` | x86_64-linux | `nh os switch . -H desktop` |
| `Shanes-MacBook-Pro` | aarch64-darwin | `nh darwin switch . -H Shanes-MacBook-Pro` |
| `Shanes-Work-MacBook-Pro` | aarch64-darwin | `nh darwin switch . -H Shanes-Work-MacBook-Pro` |
| `hetzvps` | aarch64-linux | deploy-rs (server, not local) |

Build only (no activation): `nh {os,darwin} build . -H <host>`. Live-iterate a flake input: `nrs-iter`.

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

## Tooling — use THESE

| Task | Use | NOT |
|---|---|---|
| Build / switch | `nh os switch . -H <host>` | `nixos-rebuild switch --flake ...` |
| Hash + fetcher block | `nurl <url> <rev>` | `nix-prefetch-url --unpack` + `nix-hash --to-sri` |
| Find pkg by binary | `nix-locate -w -t x --minimal bin/<cmd>` | `nh search` for known bins |
| Remote pkg search | `nh search <q>` | `nix search nixpkgs` |
| Local options / docs | `manix <opt>` | grep nixpkgs |
| New package draft | `nix-init <url>` | hand-write `buildNpmPackage` / `buildGoModule` |
| Run-once no-install | `, <cmd>` | `nix shell nixpkgs#<pkg> -c` |
| Lint | `statix check <p>` then `statix fix <p>` | manual review |
| Dead code | `deadnix <p>` | manual review |
| Format | `nix fmt` (nixfmt-rfc-style, tracked + staged) | manual |

## Done criteria for a nix edit

1. `git add` new files — flakes ignore untracked
2. `statix check <changed>` clean
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

`home/shane/modules/common/ai/`:
- `mcp/` — canonical `programs.mcp.servers` registry shared by Claude Code and Codex. Prefer pinned Nix packages for server binaries; runtime wrappers are only for secrets.
- `cc/` — Claude Code. Settings, hooks, theme, plugins via `programs.claude-code` module. Private values (work URLs, work email) come from `inputs.nix-config-private`.
- `codex/` — Codex CLI. Settings, hooks, skills, rules, and Vex AGENTS.md context via `programs.codex`.

Claude Code uses tweakcc's `claudeMdAltNames` patch, with `AGENTS.md` as the first fallback when no project `CLAUDE.md` exists. Keep this root file as the shared project rules file unless there is a specific reason to split harness behaviour.

## Git

Flakes only see git-tracked files. `git add` new files BEFORE building. Untracked → invisible to the build → confusing errors.
