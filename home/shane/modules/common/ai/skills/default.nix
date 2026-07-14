{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  ecosystemSkills = inputs.ai-skills.lib.skillProfiles.${system}.ecosystemSkills;
in
{
  home.file = lib.mapAttrs' (
    name: source:
    lib.nameValuePair ".agents/skills/${name}" {
      inherit source;
      recursive = true;
      force = true;
    }
  ) ecosystemSkills;
}
