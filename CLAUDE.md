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

**Secondary path: agenix for deployment / server-side / file-shaped
secrets that don't fit the rbw model.** Encrypted `.age` files live in
`secrets/`. Public keys and secret declarations are in:

- `secrets/secrets.nix` — maps `.age` files to authorised public keys
- `home/shane/modules/common/age.nix` — declares secrets for home-manager
  to decrypt at runtime

What still lives in agenix:

- `vex-core`, `vex-compaction`, `vex-session-start`, `vex-session-reload`,
  `vex-discord-token` — hetzvps deployment secrets (consumed server-side)
- `gemini` — system-prompt file (file-shaped, not a credential)
- Anything stable enough that "edit-and-rebuild" is fine

When adding a new credential, default to rbw. Only reach for agenix if
the secret is consumed by a non-interactive system service that can't
talk to the rbw agent, or if it's file-shaped rather than a single
string value.

When removing a secret: remove from all three locations (`.age` file,
`secrets.nix`, `age.nix`) and any references in nix modules.

## NixVim

Neovim is configured declaratively via [NixVim](https://nix-community.github.io/nixvim/) at `home/shane/modules/common/nixvim/`.

- `default.nix` — main entry point, enables nixvim with aliases and imports
- `plugins/default.nix` — aggregator that imports all individual plugin modules
- Each plugin is a self-contained module in `plugins/<name>.nix`

**Platform-specific packages:** Some plugins reference Darwin-only packages (e.g. `xcbeautify`, `swiftformat`, `swiftlint`, `sourcekit`). Guard these with `lib.mkIf pkgs.stdenv.isDarwin` or `lib.optionals pkgs.stdenv.isDarwin` to prevent Linux build failures.

## AI Modules

AI tool configs live under `home/shane/modules/common/ai/`:

- `mcp/` — shared MCP server definitions (neovim, obsidian, posthog), imported by Claude Code, Claude Desktop, and Gemini. The xero-mcp wrapper pulls `XERO_CLIENT_ID`/`XERO_CLIENT_SECRET` from rbw.
- `cc/` — Claude Code: settings, permissions, hooks, native custom theme (`vex-theme.json`)
- `cdesktop/` — shared Claude Desktop MCP selection; platform-specific wrappers remain in `modules/linux/claude-desktop.nix` and `modules/macos/claude.nix`
- `gemini/` — Gemini CLI settings and theme. Still references `config.age.secrets.gemini.path` because the secret is a system-prompt *file*, not a credential string.

## Git Hygiene

When creating new files (secrets, modules, configs), always `git add` them before building. Nix flakes only see files tracked by git — untracked files are invisible to the build and will cause confusing errors.
