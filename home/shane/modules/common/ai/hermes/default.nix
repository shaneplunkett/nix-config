{ inputs, ... }:
let
  aiSkills = inputs.ai-skills;

  soul = builtins.concatStringsSep "\n\n" [
    (builtins.readFile "${aiSkills}/vex/adapters/hermes.md")
    (builtins.readFile "${aiSkills}/vex/rules/shane-profile.md")
    (builtins.readFile "${aiSkills}/vex/rules/exec-function.md")
    (builtins.readFile "${aiSkills}/vex/rules/protocols.md")
    (builtins.readFile "${aiSkills}/vex/rules/brain.md")
  ];
in
{
  home.file.".hermes/profiles/vex/SOUL.md".text = soul;
}
