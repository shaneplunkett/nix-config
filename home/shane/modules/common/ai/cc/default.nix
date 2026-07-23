{
  config,
  pkgs,
  lib,
  inputs,
  aiHelpers,
  ...
}:
let
  priv = inputs.nix-config-private.values;
  inherit (aiHelpers) aiSkillsRoot skillProfiles;

  claudePrompt = pkgs.writeText "claude-code-CLAUDE.md" (
    aiHelpers.readMarkdownBundle [
      "${aiSkillsRoot}/work-claude/Prompt.md"
      "${aiSkillsRoot}/vex/rules/brain.md"
      "${aiSkillsRoot}/vex/rules/cli-routing.md"
    ]
  );

  gitCommitGuard = aiHelpers.mkCommitGuard "claude";

  claudeStatusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.python3 ];
    text = "exec python3 ${./vex-statusline.py}";
  };

  claudeStatusLine = {
    type = "command";
    command = "/home/shane/.local/bin/ahvi-statusline.sh ${claudeStatusline}/bin/claude-statusline";
  };

  claudeSettings = {
    feedbackSurveyRate = 0;
    autoMemoryEnabled = false;
    model = "opus";
    statusLine = claudeStatusLine;
    env = {
      OTEL_RESOURCE_ATTRIBUTES = "autograb_user=${priv.autograbUser},team=${priv.autograbTeam}";
    };
    hooks = {
      PreToolUse = [
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

  settingsFile = pkgs.writeText "claude-code-settings.json" (
    builtins.toJSON (
      claudeSettings
      // {
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      }
    )
  );

  mkClaudeProfile =
    name: configDir:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        mkdir -p "$HOME/${configDir}"
        export CLAUDE_CONFIG_DIR="$HOME/${configDir}"
        exec ${lib.getExe config.programs.claude-code.finalPackage} --dangerously-skip-permissions "$@"
      '';
    };

  claudeWork = mkClaudeProfile "claude-work" ".claude-work";
  claudeWorkExe = lib.getExe claudeWork;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-latest;
    settings = claudeSettings;
    enableMcpIntegration = true;
    skills = { };
  };

  programs.fish.shellAliases = {
    ccw = claudeWorkExe;
    ccwr = "${claudeWorkExe} --resume";
  };

  home = {
    packages = [
      claudeWork
    ];

    file = {
      ".claude-work/CLAUDE.md" = {
        source = claudePrompt;
        force = true;
      };
      ".claude-work/settings.json" = {
        source = settingsFile;
        force = true;
      };
    }
    // aiHelpers.mkSkillTree {
      dir = ".claude-work/skills";
      skills = skillProfiles.claudeWork;
      recursive = true;
    };
  };
}
