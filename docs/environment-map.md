# Environment Map

Where everything lives, how it reaches a machine, and the one rule that decides
where new things go. Last verified 12/08/2026. When an input is added or
removed in `flake.nix`, update this file in the same change.

A fuller session-generated version (with hygiene findings and host state) is
kept locally at `~/environment-map.html`; this file is the durable, public-safe
core.

## The shape

```
personal repos (flake inputs)          the hub                  deploys to
──────────────────────────────         ────────────             ──────────────────
vex-tooling      ─ CLIs/MCP  ─┐
ai-skills        ─ skills    ─┤
nix-config-private ─ values  ─┼──►  nix-config  ──►  desktop · hetzvps ·
vex-code         ─ source    ─┤     (this repo)      2× MacBook (darwin)
noctalia-plugins ─ QML       ─┘
```

## Personal flake inputs

| Input | Checkout | Provides | Consumed via |
|---|---|---|---|
| `vex-tooling` | `~/projects/personal/vex-tooling` | Agent-stack CLIs and MCP servers: `vex`, `langsmith`, `agent-slack`, `gws`, `tvly`, `bb`, `todoist`, `confluence`, `unifi`, `linear` (managed-auth wrapper), `aikido-mcp`, `xero-mcp-server` (on hold, unwired). Credentials injected from rbw at invocation. | `overlays.default` in `lib/common.nix` + `homeManagerModules.default` on the desktop and darwin hosts only (servers opt out via `agentClis = false` in `flake.nix`) |
| `ai-skills` | `~/ai-skills` | `lib.skillProfiles` (claudeWork / codex / allSkills) and the CLAUDE.md prompt sources. Carries its own skill inputs (work skills, langsmith-skills, matt-skills, tavily-skills, sanitised linear-cli skill). | `home/shane/modules/common/ai/lib.nix` |
| `nix-config-private` | `~/projects/personal/nix-config-private` | Private `values` and work-specific home-manager modules. Zero inputs of its own. | `homeManagerModules.default` + `inputs.nix-config-private.values` in the AI modules |
| `vex-code` | `~/projects/personal/vex-code` | Source only (`flake = false`); this repo's `pkgs/vex-code` owns the build. | `pkgs/default.nix` (`vexCodeSrc`) |
| `noctalia-plugins` | `~/projects/personal/noctalia-plugins` | Noctalia QML plugins, symlinked live from the local checkout (QML edits need no rebuild; deployment changes do). | `home/shane/modules/linux/noctalia-plugins.nix` |

In-repo `pkgs/` holds everything else: desktop apps, themed builds, the
vex-code package, editor tooling. See the residency rule below.

## Residency rule

One sentence decides where a new thing goes:

- **Agent runtime** (any CLI or MCP server the agent stack invokes) → `vex-tooling`
- **Skills, prompts, agent personas** → `ai-skills`
- **Private values and work-specific modules** → `nix-config-private`
- **Desktop apps, themes, machine config** → this repo's `pkgs/`

## Update chains

**Chain A — bump a CLI or MCP server version (e.g. langsmith):**

1. In `vex-tooling`: bump version + hashes in `pkgs/<name>/<name>.nix`
   (`nix-update` handles most). Commit, push.
2. Here: `nix flake update vex-tooling`, commit the lock.
3. Rebuild: `nh os switch . -H <host>`.

If a CLI looks stale, check vex-tooling first — this repo's lock usually
tracks its HEAD, so stale versions mean nobody bumped the package there.

**Chain B — change a skill, prompt, or CLAUDE.md content:**

1. Edit in `ai-skills` (a dir with `SKILL.md` under `personal/` is
   auto-discovered). Commit, push.
2. Here: `nix flake update ai-skills`, rebuild.

**Chain C — pick up new work skills (deepest chain, three repos):**

1. The work skills repo changes upstream.
2. In `ai-skills`: `nix flake update ag-ai-skills`, commit, push.
3. Here: `nix flake update ai-skills`, rebuild.
4. Same pattern for the other skill inputs (matt-skills, tavily-skills,
   langsmith-skills, linear-cli).

**Chain D — everything else:**

- Private values: edit `nix-config-private` → push → `nix flake update nix-config-private` → rebuild.
- Vex Code: push to the fork → `nix flake update vex-code` → rebuild.
- claude-code / codex CLIs: `nix flake update llm-agents` → rebuild (cache-backed).
- Desktop apps and machine config: edit `pkgs/` or modules here → rebuild. One repo, no chain.

## Adjacent territory (not flake inputs — never affects rebuilds)

- `~/flakes` — one repo of per-project dev shells (`autograb/*` pointing at
  work checkouts, `nix-config-tools` for hacking on this repo).
- `~/projects/personal` — personal repo checkouts, including the five input
  repos above (except ai-skills, which lives at `~/ai-skills`).
- `~/projects/work` — work checkouts. Nothing here feeds this flake.
