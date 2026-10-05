# Environment Map

Where everything lives, how it reaches a machine, and the one rule that decides
where new things go. Last verified 05/10/2026. When an input is added or
removed in `flake.nix`, update this file in the same change.

A fuller session-generated version (with hygiene findings and host state) is
kept locally at `~/environment-map.html`; this file is the durable, public-safe
core.

## The shape

```
personal repos (flake inputs)          the hub                  deploys to
──────────────────────────────         ────────────             ──────────────────
vex-brain         ─ vex CLI    ─┐
ai-skills         ─ skills     ─┤
nix-config-private ─ private HM ─┼──►  nix-config  ──►  desktop · MacBook ·
vex-code          ─ source     ─┤     (this repo)      mini-server
noctalia-plugins  ─ QML        ─┘
```

## Personal flake inputs

| Input | Checkout | Provides | Consumed via |
|---|---|---|---|
| `vex-brain` | `~/Projects/personal/vex-brain` | The `vex` CLI and its hourly session sync jobs, next to the server they talk to. On mini-server the sync runs as boot-time daemons (`darwinModules.vex-sync`), reading CF Access creds from `/etc/vex-sync/credentials`; see vex-brain's `docs/runbooks/vex-sync-mini-server.md`. | `homeManagerModules.vex-cli` in `lib/nixos.nix` and `lib/darwin.nix`; `darwinModules.vex-sync` on mini-server in `flake.nix` |
| `ai-skills` | `~/ai-skills` | `lib.skillProfiles` used by the local AI modules, plus the prompt sources they install. Carries its own skill inputs. | `home/shane/modules/common/ai/lib.nix` |
| `nix-config-private` | `~/Projects/personal/nix-config-private` | Private home-manager modules and deliberately private desktop utilities. Zero inputs of its own. | `homeManagerModules.default` |
| `vex-code` | `~/Projects/personal/vex-code` | Source only (`flake = false`); this repo's `pkgs/vex-code` owns the build. | `pkgs/default.nix` (`vexCodeSrc`) |
| `noctalia-plugins` | `~/Projects/personal/noctalia-plugins` | Noctalia plugins written for v4's QML API. Not wired in since the v5 move; kept for the plugin port. | Nothing yet |

In-repo `pkgs/` holds everything else: desktop apps, themed builds, the
vex-code package, editor tooling, and the agent-stack CLIs (`tvly`, `bb`,
`langsmith`, `todoist`, `unifi`). Those CLIs are wrapped by
`home/shane/modules/agent-clis`, which injects credentials from rbw at
invocation. See the residency rule below.

## Residency rule

One sentence decides where a new thing goes:

- **Agent runtime** (any CLI or MCP server the agent stack invokes) → this repo's `pkgs/`, wrapped in `home/shane/modules/agent-clis`
- **Skills, prompts, agent personas** → `ai-skills`
- **Private modules and deliberately private desktop utilities** → `nix-config-private`
- **Other desktop apps, themes, and machine config** → this repo's `pkgs/`

## Update chains

**Chain A — bump a CLI or MCP server version (e.g. langsmith):**

1. Here: bump version + hashes in `pkgs/<name>/default.nix`
   (`nix-update --flake <name>` handles most; langsmith carries one hash per
   platform). Commit.
2. Rebuild: `nh os switch . -H <host>`.

**Chain B — change a skill or prompt source:**

1. Edit in `ai-skills` (a dir with `SKILL.md` under `personal/` is
   auto-discovered). Commit, push.
2. Here: `nix flake update ai-skills`, rebuild.

**Chain C — pick up new skill inputs (deepest chain, three repos):**

1. One of the upstream skill repos changes.
2. In `ai-skills`: update the relevant flake input, commit, push.
3. Here: `nix flake update ai-skills`, rebuild.
4. Same pattern for the other skill inputs.

**Chain D — everything else:**

- Private values, modules, or utilities: edit `nix-config-private` → push → `nix flake update nix-config-private` → rebuild.
- Vex Code: push to the fork → `nix flake update vex-code` → rebuild.
- vex CLI and sync jobs: merge in vex-brain → `nix flake update vex-brain` → rebuild.
- Claude Code, Codex CLI, and Linux Claude/ChatGPT desktop apps: `nix flake update llm-agents` → rebuild (cache-backed).
- Desktop apps and machine config: edit `pkgs/` or modules here → rebuild. One repo, no chain.

## Adjacent territory (not flake inputs — never affects rebuilds)

- `~/flakes` — one repo of per-project dev shells, including
  `nix-config-tools` for hacking on this repo.
- `~/Projects/personal` — personal repo checkouts, including the five input
  repos above (except ai-skills, which lives at `~/ai-skills`).
