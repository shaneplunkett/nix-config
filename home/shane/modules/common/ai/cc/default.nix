{
  pkgs,
  aiHelpers,
  ...
}:
let
  inherit (aiHelpers) aiSkillsRoot skillProfiles;

  claudePrompt = aiHelpers.readMarkdownBundle [
    "${aiSkillsRoot}/personal-claude/Prompt.md"
    "${aiSkillsRoot}/vex/rules/brain.md"
    "${aiSkillsRoot}/vex/rules/cli-routing.md"
  ];
in
{
  programs = {
    claude-code = {
      enable = true;
      package = pkgs.claude-code;
      context = claudePrompt;
      enableMcpIntegration = true;
      skills = skillProfiles.claude;

      settings = {
        feedbackSurveyRate = 0;
        autoMemoryEnabled = false;
        model = "opus";
        extraKnownMarketplaces.openai-codex.source = {
          source = "github";
          repo = "openai/codex-plugin-cc";
        };
        enabledPlugins."codex@openai-codex" = true;
        hooks = aiHelpers.hooksFor "claude";
      };
    };

    fish.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      ccr = "claude --dangerously-skip-permissions --resume";
    };
  };
}
