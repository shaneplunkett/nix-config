{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./skills
    ./mcp
    ./codex
  ];

  # One shared helper set for the harness modules; see ./lib.nix.
  _module.args.aiHelpers = import ./lib.nix { inherit pkgs lib inputs; };
}
