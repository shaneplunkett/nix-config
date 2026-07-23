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
  configDir = ".claude-work";

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

  claudeWork = mkClaudeProfile "claude-work" configDir;
  claudeWorkExe = lib.getExe claudeWork;
in
{
  # Published artifacts other modules consume (e.g. vex-code); reading these
  # options instead of guessing paths makes the coupling eval-checked.
  options.vex.ai.claude = {
    configDir = lib.mkOption {
      type = lib.types.str;
      description = "Home-relative directory of the Claude Code work profile.";
    };
    workWrapper = lib.mkOption {
      type = lib.types.package;
      description = "Wrapper that launches Claude Code against the work profile.";
    };
  };

  config = {
    vex.ai.claude = {
      inherit configDir;
      workWrapper = claudeWork;
    };

    programs.claude-code = {
      enable = true;
      package = pkgs.claude-code;
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
        "${configDir}/CLAUDE.md" = {
          source = claudePrompt;
          force = true;
        };
        "${configDir}/settings.json" = {
          source = settingsFile;
          force = true;
        };
      }
      // aiHelpers.mkSkillTree {
        dir = "${configDir}/skills";
        skills = skillProfiles.claudeWork;
        recursive = true;
      };
    };
  };
}
