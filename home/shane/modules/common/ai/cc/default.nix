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

  gitCommitGuard = aiHelpers.mkCommitGuard "claude";
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
        # Marketplace only; plugins from it are installed per project.
        extraKnownMarketplaces.openai-codex.source = {
          source = "github";
          repo = "openai/codex-plugin-cc";
        };
        hooks.PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "${gitCommitGuard}/bin/claude-git-commit-guard";
                timeout = 10;
              }
            ];
          }
        ];
      };
    };

    fish.shellAliases = {
      cc = "claude --dangerously-skip-permissions";
      ccr = "claude --dangerously-skip-permissions --resume";
    };
  };
}
