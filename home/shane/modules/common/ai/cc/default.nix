{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  priv = inputs.nix-config-private.values;
  aiSkillsRoot = inputs.ai-skills.outPath;
  system = pkgs.stdenv.hostPlatform.system;
  skillProfiles = inputs.ai-skills.lib.skillProfiles.${system};
  workPrompt = "${aiSkillsRoot}/work-claude/Prompt.md";
  brainRule = "${aiSkillsRoot}/vex/rules/brain.md";
  cliRoutingRule = "${aiSkillsRoot}/vex/rules/cli-routing.md";

  claudePrompt = pkgs.writeText "claude-code-CLAUDE.md" (
    lib.concatStringsSep "\n\n" (
      map builtins.readFile [
        workPrompt
        brainRule
        cliRoutingRule
      ]
    )
  );

  gitCommitGuard = pkgs.writeShellApplication {
    name = "claude-git-commit-guard";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
    ];
    text = ''exec ${pkgs.bash}/bin/bash ${../git-commit-guard.sh} claude "$@"'';
  };

  claudeStatusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.python3 ];
    text = "exec python3 ${./vex-statusline.py}";
  };

  claudeStatusLine = {
    type = "command";
    command = "/home/shane/.local/bin/ahvi-statusline.sh ${claudeStatusline}/bin/claude-statusline";
  };

  mkSkillEntries =
    configDir: skills:
    lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${configDir}/skills/${name}" {
        inherit source;
        recursive = true;
        force = true;
      }
    ) skills;

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

  claudePersonal = mkClaudeProfile "claude-personal" ".claude";
  claudeWork = mkClaudeProfile "claude-work" ".claude-work";
  claudePersonalExe = lib.getExe claudePersonal;
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

  # Keep `cc` as an interactive convenience only. A real `cc` binary collides
  # with C compiler wrappers inside dev shells.
  programs.fish.shellAliases = {
    cc = claudePersonalExe;
    ccr = "${claudePersonalExe} --resume";
    ccw = claudeWorkExe;
    ccwr = "${claudeWorkExe} --resume";
  };

  home = {
    packages = [
      claudePersonal
      claudeWork
    ];

    file = {
      ".claude/CLAUDE.md" = {
        source = claudePrompt;
        force = true;
      };
      ".claude-work/CLAUDE.md" = {
        source = claudePrompt;
        force = true;
      };
      ".claude-work/settings.json" = {
        source = settingsFile;
        force = true;
      };
    }
    // mkSkillEntries ".claude" skillProfiles.claudePersonal
    // mkSkillEntries ".claude-work" skillProfiles.claudeWork;
  };
}
