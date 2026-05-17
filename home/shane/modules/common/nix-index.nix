_: {
  # Pre-computed nixpkgs file-path index. Enables:
  # - `nix-locate -1 <bin>` for instant package lookup by binary name
  # - `command-not-found` shell hook: typing a missing command suggests
  #   the exact `pkgs.<name>` that provides it
  # - `,` (comma) resolves commands against the local DB instead of
  #   evaluating the nixpkgs flake live (cache level 2 ≈ 159× faster
  #   per comma's own benchmarks).
  #
  # Database itself comes from the `nix-index-database` flake input;
  # this module just enables the home-manager bits.
  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  # Re-point `comma` at the local nix-index database. Without this comma
  # still works but resolves against a live flake eval.
  programs.nix-index-database.comma.enable = true;
}
