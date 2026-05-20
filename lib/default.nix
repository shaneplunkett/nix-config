{
  inputs,
  rootPath ? ../.,
}:
{
  inherit (import ./darwin.nix { inherit inputs rootPath; }) mkDarwinSystem;
  inherit (import ./nixos.nix { inherit inputs rootPath; }) mkNixosSystem;
}
