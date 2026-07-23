{ aiHelpers, ... }:
{
  home.file = aiHelpers.mkSkillTree {
    dir = ".agents/skills";
    skills = aiHelpers.skillProfiles.ecosystemSkills;
  };
}
