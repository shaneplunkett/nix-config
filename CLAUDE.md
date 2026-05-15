# Nix Config

## Build Commands

**NixOS (desktop):**

```bash
nixos-rebuild build --flake .#desktop    # test build only
sudo nixos-rebuild switch --flake .#desktop  # build and activate
```

**Darwin (personal):**

```bash
darwin-rebuild build --flake .#Shanes-MacBook-Pro
darwin-rebuild switch --flake .#Shanes-MacBook-Pro
```

**Darwin (work):**

```bash
darwin-rebuild build --flake .#Shanes-Work-MacBook-Pro
darwin-rebuild switch --flake .#Shanes-Work-MacBook-Pro
```

## Secrets Management

**Primary path: rbw (Bitwarden CLI) for all day-to-day API tokens and
credentials.** Every CLI wrapper in `home/shane/modules/common/` reads from
rbw at invocation time. Rotation flow: edit the Bitwarden entry in the
web/desktop UI → `rbw sync` → next CLI invocation picks up the new value.
No rebuild required.

- `home/shane/modules/common/rbw.nix` — declares `programs.rbw` with
  `email`, `lock_timeout`, and platform-aware `pinentry`
  (`pinentry-curses` on Linux, `pinentry_mac` on Darwin)
- One-time setup per machine: `rbw unlock` (master password + 2FA)
  unlocks the agent for the lifetime of the boot session
  (`lock_timeout = 604800`)
- Wrapper pattern: each CLI wrapper shells out to
  `${pkgs.rbw}/bin/rbw get <entry-name>` inside a `makeWrapper --run`
  block. If the agent is locked or the entry is missing, the env var
  stays unset rather than erroring — let the downstream tool complain.

**Secondary path: agenix for deployment / server-side secrets that can't
talk to the rbw agent.** Currently used only by the hetzvps host —
no home-manager-scope agenix secrets remain. Encrypted `.age` files live
in `secrets/`. Public keys and secret declarations are in:

- `secrets/secrets.nix` — maps `.age` files to authorised public keys
- Per-host nix modules consume them via `config.age.secrets.<name>.path`
  (e.g. `hosts/hetzvps/modules/services.nix` for tailscale-authkey)

What still lives in agenix:

- `tailscale-authkey`, `restic-password` — hetzvps deployment secrets
- `vex-core`, `vex-compaction`, `vex-session-start`, `vex-session-reload`,
  `vex-discord-token` — hetzvps vex-brain secrets (consumed server-side)

When adding a new credential, default to rbw. Only reach for agenix if
the secret is consumed by a non-interactive system service that can't
talk to the rbw agent.

When removing a secret: remove the `.age` file, the `secrets.nix` entry,
and any module references. If a new home-manager-scope file-shaped secret
is ever needed, re-add `agenix.homeManagerModules.default` to
`lib/common.nix` sharedModules (removed when gemini was last HM agenix
consumer).

## NixVim

Neovim is configured declaratively via [NixVim](https://nix-community.github.io/nixvim/) at `home/shane/modules/common/nixvim/`.

- `default.nix` — main entry point, enables nixvim with aliases and imports
- `plugins/default.nix` — aggregator that imports all individual plugin modules
- Each plugin is a self-contained module in `plugins/<name>.nix`

**Platform-specific packages:** Some plugins reference Darwin-only packages (e.g. `xcbeautify`, `swiftformat`, `swiftlint`, `sourcekit`). Guard these with `lib.mkIf pkgs.stdenv.isDarwin` or `lib.optionals pkgs.stdenv.isDarwin` to prevent Linux build failures.

## AI Modules

AI tool configs live under `home/shane/modules/common/ai/`:

- `mcp/` — shared MCP server definitions (neovim, xero), imported by Claude Code. The xero-mcp wrapper pulls `XERO_CLIENT_ID`/`XERO_CLIENT_SECRET` from rbw.
- `cc/` — Claude Code: settings, permissions, hooks, native custom theme (`vex-theme.json`), plugins + marketplaces via `programs.claude-code` module

## Git Hygiene

When creating new files (secrets, modules, configs), always `git add` them before building. Nix flakes only see files tracked by git — untracked files are invisible to the build and will cause confusing errors.
