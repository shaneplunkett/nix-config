{ inputs, rootPath ? ../. }:
{
  # Import helper functions with root path
  inherit (import ./darwin.nix { inherit inputs rootPath; }) mkDarwinSystem;
  inherit (import ./nixos.nix { inherit inputs rootPath; }) mkNixosSystem;
}