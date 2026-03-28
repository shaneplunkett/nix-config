# Nix Config

## Build Commands

**NixOS (desktop):**

```bash
nios-rebuild build --flake .#desktop    # test build only
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

Secrets are managed with [agenix](https://github.com/ryantm/agenix). Encrypted `.age` files live in `secrets/`. Public keys and secret declarations are in:

- `secrets/secrets.nix` — maps `.age` files to authorised public keys
- `home/shane/modules/common/age.nix` — declares secrets for home-manager to decrypt at runtime

When adding a new secret: create the `.age` file with `agenix -e secrets/<name>.age`, add the public key entry to `secrets/secrets.nix`, and declare it in `age.nix`.

When removing a secret: remove from all three locations (`.age` file, `secrets.nix`, `age.nix`) and any references in nix modules.

## NixVim

Neovim is configured declaratively via [NixVim](https://nix-community.github.io/nixvim/) at `home/shane/modules/common/nixvim/`.

- `default.nix` — main entry point, enables nixvim with aliases and imports
- `plugins/default.nix` — aggregator that imports all individual plugin modules
- Each plugin is a self-contained module in `plugins/<name>.nix`

**Platform-specific packages:** Some plugins reference Darwin-only packages (e.g. `xcbeautify`, `swiftformat`, `swiftlint`, `sourcekit`). Guard these with `lib.mkIf pkgs.stdenv.isDarwin` or `lib.optionals pkgs.stdenv.isDarwin` to prevent Linux build failures.

## AI Modules

AI tool configs live under `home/shane/modules/common/ai/`:

- `mcp/` — shared MCP server definitions (neovim, obsidian, posthog), imported by Claude Code, Claude Desktop, and Gemini
- `cc/` — Claude Code: settings, permissions, hooks, tweakcc theme
- `cdesktop/` — shared Claude Desktop MCP selection; platform-specific wrappers remain in `modules/linux/claude-desktop.nix` and `modules/macos/claude.nix`
- `gemini/` — Gemini CLI settings and theme

## Git Hygiene

When creating new files (secrets, modules, configs), always `git add` them before building. Nix flakes only see files tracked by git — untracked files are invisible to the build and will cause confusing errors.
