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

Secrets are managed with [agenix](https://github.com/ryantm/agenix). Encrypted `.age` files live in `secrets/`. Public keys and secret declarations are in:

- `secrets/secrets.nix` — maps `.age` files to authorised public keys
- `home/shane/modules/common/age.nix` — declares secrets for home-manager to decrypt at runtime

When adding a new secret: create the `.age` file with `agenix -e secrets/<name>.age`, add the public key entry to `secrets/secrets.nix`, and declare it in `age.nix`.

When removing a secret: remove from all three locations (`.age` file, `secrets.nix`, `age.nix`) and any references in nix modules.

## Git Hygiene

When creating new files (secrets, modules, configs), always `git add` them before building. Nix flakes only see files tracked by git — untracked files are invisible to the build and will cause confusing errors.
