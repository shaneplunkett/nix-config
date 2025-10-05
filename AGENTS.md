# AGENTS.md - Coding Guidelines for Nix Configuration

## Build/Test Commands
- **Build**: `nix build .#darwinConfigurations."Shanes-MacBook-Pro".system` (macOS) or `nixos-rebuild build` (Linux)
- **Switch**: `darwin-rebuild switch --flake .` (macOS) or `nixos-rebuild switch --flake .` (Linux)
- **Check**: `nix flake check` - validates flake syntax and dependencies
- **Format**: `nixfmt` for .nix files (configured in conform.nix)
- **No traditional tests** - Nix configurations are validated through successful builds

## Code Style Guidelines
- **File extension**: Always use `.nix` for Nix files
- **Imports**: Place `imports = [ ... ];` at the top of configurations
- **Formatting**: Use nixfmt for consistent formatting (2-space indentation)
- **Naming**: Use kebab-case for file names, camelCase for attribute names
- **Structure**: Organize by `imports`, then configuration attributes
- **Comments**: Use `#` for single-line comments, avoid excessive commenting
- **Strings**: Use double quotes for strings, single quotes for paths when needed
- **Functions**: Define with `{ ... }:` pattern, use descriptive parameter names

## Error Handling
- Nix fails fast on evaluation errors - fix syntax issues immediately
- Use `lib.mkIf` for conditional configurations
- Leverage `lib.optional` and `lib.optionals` for optional list items
- Check flake inputs are properly declared and used

## Architecture Notes
- **Flake-based**: All configurations use Nix flakes with inputs/outputs
- **Home Manager**: User configurations managed via home-manager modules
- **Modular**: Configurations split into logical modules (nixvim, packages, etc.)
- **Cross-platform**: Supports both NixOS (Linux) and nix-darwin (macOS)