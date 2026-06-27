{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Private values (work URLs / email attributes) live in the companion
  # nix-config-private flake input. The public flake stays clean.
  priv = inputs.nix-config-private.values;

  # Vex persona + personal skills come from the ai-skills flake input (private
  # GitHub repo). Edits go via: change ai-skills repo → commit → nix flake
  # update ai-skills → rebuild. For active iteration use `nrs-iter` which
  # `--override-input`s this to ~/ai-skills (commits not even required).
  aiSkills = inputs.ai-skills;
  claudeVexStack = "${aiSkills}/vex/claude-code";

  vexThemeFile = ./vex-theme.json;

  # ─── Helper: wrap a bash script as a writeShellApplication binary. ─────
  # All shell-script-shaped hooks + the claude-restart wrapper share this
  # shape — keeps each call site to a one-liner. Always passes "$@" so the
  # script receives any positional args (hooks ignore them, the wrapper
  # uses them for CLI passthrough).
  mkBashHook =
    {
      name,
      runtimeInputs ? [ ],
      script,
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [
        pkgs.bash
        pkgs.coreutils
      ]
      ++ runtimeInputs;
      text = ''exec bash ${script} "$@"'';
    };

  # Claude status line — invoked by CC via settings.json statusLine.command.
  # Stays on writeShellApplication rather than writers.writePython3Bin
  # because the latter runs pycodestyle and our script (intentionally) has
  # long lines and a non-PEP8 shebang-as-comment.
  claude-statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.python3 ];
    text = "exec python3 ${./vex-statusline.py}";
  };

  claudeStatusLine = {
    type = "command";
    command = "/home/shane/.local/bin/ahvi-statusline.sh ${claude-statusline}/bin/claude-statusline";
  };

  claudeIdentityEnv = {
    OTEL_RESOURCE_ATTRIBUTES = "autograb_user=${priv.autograbUser},team=${priv.autograbTeam}";
  };

  claudeTelemetryEnv = claudeIdentityEnv // {
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    CLAUDE_CODE_ENABLE_TELEMETRY = "1";
    CLAUDE_CODE_ENHANCED_TELEMETRY_BETA = "1";
    OTEL_METRICS_EXPORTER = "none";
    OTEL_LOGS_EXPORTER = "otlp";
    OTEL_TRACES_EXPORTER = "otlp";
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://127.0.0.1:8421";
    OTEL_EXPORTER_OTLP_PROTOCOL = "http/json";
    OTEL_LOG_TOOL_DETAILS = "1";
    OTEL_LOG_TOOL_CONTENT = "1";
    OTEL_LOG_USER_PROMPTS = "0";
    OTEL_LOG_RAW_API_BODIES = "0";
  };

  # SessionStart / CwdChanged hook: load direnv environment into CLAUDE_ENV_FILE.
  cc-direnv-load = mkBashHook {
    name = "cc-direnv-load";
    runtimeInputs = [ pkgs.direnv ];
    script = ./cc-direnv-load.sh;
  };

  # PostToolUse hook: lint .nix files after every Edit/Write/MultiEdit and
  # surface findings to the agent as feedback. The shell script reads the
  # tool payload as JSON on stdin and exits 2 with statix/deadnix output
  # when anything's off.
  cc-nix-lint = mkBashHook {
    name = "cc-nix-lint";
    runtimeInputs = [
      pkgs.jq
      pkgs.statix
      pkgs.deadnix
    ];
    script = ./nix-lint-hook.sh;
  };

  # ─── claude-restart — restart Claude Code in-place ─────────────────────
  # Type `restart` in the prompt → UserPromptSubmit hook intercepts before
  # the model runs (zero tokens) → claude exits → wrapper respawns it with
  # --continue. Vendored & adapted from yacb2/claude-restart (MIT),
  # restart-only (handoff machinery dropped), nix-native install.
  #
  # The wrapper takes the user's invocation; fish.nix defines a `claude`
  # function that calls this binary, so personal `cc`/`ccr` route through it.
  # Work/plain aliases intentionally bypass this.
  claude-restart = mkBashHook {
    name = "claude-restart";
    script = ./claude-restart-wrapper.sh;
  };

  # Work profile intentionally uses pristine Claude Code. The patched native
  # tweakcc build has broken interactive Team-profile turns before, so keep a
  # clean binary available for ccw/ccwr while personal cc stays patched.
  claude-work = pkgs.writeShellApplication {
    name = "claude-work";
    text = ''exec ${lib.getExe pkgs.claude-code} "$@"'';
  };

  # Plain Claude Code profile selector for ccp/ccpr. This is deliberately
  # boring: pristine upstream binary, separate OAuth containers for
  # personal/work, and no Vex prompt/rules/hooks surface.
  claude-plain = pkgs.writeShellApplication {
    name = "claude-plain";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -euo pipefail

      usage() {
        cat <<'EOF'
      Usage:
        ccp [--personal|--work|--profile personal|work] [claude options...] [command] [prompt]
        ccpr [--personal|--work|--profile personal|work] [claude options...]

      Profiles:
        --personal   Use ~/.claude-pro (default)
        --work       Use ~/.claude-pro-work

      Plain mode runs pristine Claude Code against a de-Vexed profile with dangerous permissions enabled and built-in auto memory disabled.
      Pass Claude's own --help after --, for example: ccp -- --help
      EOF
      }

      profile="personal"
      passthrough=()

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --personal)
            profile="personal"
            shift
            ;;
          --work)
            profile="work"
            shift
            ;;
          --profile)
            if [[ $# -lt 2 ]]; then
              echo "claude-plain: --profile requires 'personal' or 'work'" >&2
              exit 64
            fi
            profile="$2"
            shift 2
            ;;
          --profile=*)
            profile="''${1#--profile=}"
            shift
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          --)
            shift
            passthrough+=("$@")
            break
            ;;
          *)
            passthrough+=("$1")
            shift
            ;;
        esac
      done

      case "$profile" in
        personal)
          config_dir="''${CLAUDE_PLAIN_PERSONAL_DIR:-$HOME/.claude-pro}"
          ;;
        work)
          config_dir="''${CLAUDE_PLAIN_WORK_DIR:-$HOME/.claude-pro-work}"
          ;;
        *)
          echo "claude-plain: profile must be 'personal' or 'work'" >&2
          exit 64
          ;;
      esac

      mkdir -p "$config_dir"
      CLAUDE_CONFIG_DIR="$config_dir" exec ${lib.getExe pkgs.claude-code} --dangerously-skip-permissions "''${passthrough[@]}"
    '';
  };

  # Non-interactive Claude worker wrapper. It selects an OAuth profile but runs
  # in safe-mode, so profile dirs are only auth containers; no custom context,
  # hooks, skills, plugins, MCP servers, or CLAUDE.md files are loaded.
  claude-delegate = pkgs.writeShellApplication {
    name = "claude-delegate";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      set -euo pipefail

      usage() {
        cat <<'EOF'
      Usage:
        claude-delegate [work|personal] [options] [prompt...]

      Options:
        --profile work|personal  Select OAuth profile (default: work)
        --model MODEL            Claude model alias/name (default: opus)
        --tools TOOLS            Built-in tools list (default: Read,Grep,Glob,Bash)
        --write                  Also expose Edit,Write,MultiEdit
        --max-budget-usd VALUE   Print-mode spend cap
        -h, --help               Show this help

      If no prompt arguments are supplied, stdin is used.
      EOF
      }

      profile="work"
      model="''${CLAUDE_DELEGATE_MODEL:-opus}"
      tools="Read,Grep,Glob,Bash"
      max_budget=0
      prompt_parts=()

      while [[ $# -gt 0 ]]; do
        case "$1" in
          work|personal)
            profile="$1"
            shift
            ;;
          --profile)
            profile="''${2:-}"
            shift 2
            ;;
          --model)
            model="''${2:-}"
            shift 2
            ;;
          --tools)
            tools="''${2:-}"
            shift 2
            ;;
          --write)
            tools="Read,Grep,Glob,Bash,Edit,Write,MultiEdit"
            shift
            ;;
          --max-budget-usd)
            max_budget="''${2:-}"
            shift 2
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          --)
            shift
            prompt_parts+=("$@")
            break
            ;;
          *)
            prompt_parts+=("$1")
            shift
            ;;
        esac
      done

      case "$profile" in
        work)
          config_dir="''${CLAUDE_DELEGATE_WORK_DIR:-$HOME/.claude-work}"
          ;;
        personal)
          config_dir="''${CLAUDE_DELEGATE_PERSONAL_DIR:-$HOME/.claude}"
          ;;
        *)
          echo "claude-delegate: profile must be 'work' or 'personal'" >&2
          exit 64
          ;;
      esac

      if [[ ! -d "$config_dir" ]]; then
        echo "claude-delegate: config dir does not exist: $config_dir" >&2
        exit 66
      fi

      if [[ ''${#prompt_parts[@]} -gt 0 ]]; then
        prompt="''${prompt_parts[*]}"
      else
        prompt="$(cat)"
      fi

      if [[ -z "$prompt" ]]; then
        echo "claude-delegate: prompt is empty" >&2
        exit 64
      fi

      args=(
        --safe-mode
        --no-chrome
        --no-session-persistence
        --print
        --output-format text
        --model "$model"
        --permission-mode bypassPermissions
        --tools "$tools"
      )

      if [[ "$max_budget" != "0" ]]; then
        args+=(--max-budget-usd "$max_budget")
      fi

      CLAUDE_CONFIG_DIR="$config_dir" exec ${lib.getExe claude-work} "''${args[@]}" -- "$prompt"
    '';
  };

  # UserPromptSubmit hook for claude-restart: intercepts the literal word
  # `restart` (trimmed, case-insensitive), touches the per-wrapper flag,
  # SIGTERMs claude, and blocks the prompt from reaching the model.
  cc-restart-hook = mkBashHook {
    name = "cc-restart-hook";
    runtimeInputs = [ pkgs.jq ];
    script = ./restart-hook.sh;
  };

  # ─── Plugins — deliberately NOT managed by Nix ─────────────────────────
  # Plugins and marketplaces are fully imperative. Claude owns the writable
  # state in ~/.claude/plugins/{installed_plugins,known_marketplaces}.json,
  # so `/plugin install`, `/plugin marketplace add`, and enable/disable
  # toggles all just work and persist with zero rebuild. Nix used to assert
  # `enabledPlugins` + `extraKnownMarketplaces` into the read-only settings.json
  # symlink, which froze the toggle state and forced a rebuild for every swap.
  # Trade-off accepted: a fresh machine starts with no plugins; re-add by hand.
  # When a baseline settles, promote it back here (seed-once into the writable
  # cache, mirroring the codex config.toml pattern) rather than re-freezing
  # settings.json.

  # ─── ai-skills (personal skills + vex persona) ─────────────────────────
  # Personal skills are directories under ai-skills/personal/. Enumerated at
  # eval time from the flake input — replaces the runtime-iteration activation
  # script that used to walk ~/ai-skills/personal/ at switch time.
  #
  # Helper: enumerate subdirectory names in `enumSrc` and map each to a
  # value under `valueRoot`.
  mkSkillsAttrs =
    enumSrc: valueRoot:
    lib.listToAttrs (
      map (name: {
        inherit name;
        value = "${valueRoot}/${name}";
      }) (lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir enumSrc)))
    );

  personalSkillsAttrs = mkSkillsAttrs "${aiSkills}/personal" "${aiSkills}/personal";

  # Keep default Claude sessions lean. Work and project-specific skills are
  # exposed through repo-local .agents/skills and .claude/skills symlinks.
  globalSkillNames = [
    "memory-save"
    "tavily-best-practices"
    "tavily-cli"
    "tavily-crawl"
    "tavily-dynamic-search"
    "tavily-extract"
    "tavily-map"
    "tavily-research"
    "tavily-search"
    "td-todoist"
  ];
  globalSkillsAttrs = lib.genAttrs globalSkillNames (name: personalSkillsAttrs.${name});

  # ─── claude-code-patched ───────────────────────────────────────────────
  # pkgs.claude-code with tweakcc-fixed applied at build time + skrabe's
  # lobotomized-claude-code system-prompt overrides baked in. The patched
  # binary is its own /nix/store derivation — survives GC, no sudo/re-apply
  # dance, nh switch re-derives when either input bumps. Knobs in
  # pkgs/claude-code-patched/config.json.
  inherit (pkgs) claude-code-patched;

  # ─── Settings content ──────────────────────────────────────────────────
  # Shape parameterised so we produce both the canonical ~/.claude Vex profile
  # managed by programs.claude-code and the ~/.claude-work Vex variant.
  mkSettingsContent =
    {
      outputStyle,
      hookSuffix,
      hookDir ? "${aiSkills}/vex/hooks",
      model ? null,
    }:
    {
      theme = "custom:vex";
      inherit outputStyle;
      spinnerTipsEnabled = false;
      spinnerVerbs = {
        mode = "replace";
        verbs = [
          "Brewing"
          "Channelling"
          "Conjuring"
          "Contemplating"
          "Crystallising"
          "Distilling"
          "Divining"
          "Enchanting"
          "Gathering"
          "Gazing"
          "Incanting"
          "Kindling"
          "Murmuring"
          "Musing"
          "Nurturing"
          "Pondering"
          "Scrying"
          "Simmering"
          "Steeping"
          "Stirring"
          "Summoning"
          "Tending"
          "Unravelling"
          "Weaving"
          "Whispering"
        ];
      };
      feedbackSurveyRate = 0;

      # The vex-brain is Shane's memory source of truth. Keep Claude Code's
      # built-in auto memory off across every generated profile.
      autoMemoryEnabled = false;

      # Plugins/marketplaces are intentionally absent here — fully imperative,
      # owned by Claude's writable plugin cache. See the note in the let block.

      env = claudeTelemetryEnv;

      # skipDangerousModePermissionPrompt is a TOP-LEVEL state flag per the
      # official schema at json.schemastore.org/claude-code-settings.json —
      # "Whether the user has accepted the bypass permissions mode dialog.
      # Typically managed by the CLI rather than set by hand." Pre-setting
      # it to true skips the prompt forever. NOT under permissions — CC
      # silently ignores it there.
      skipDangerousModePermissionPrompt = outputStyle != "vex-pro";

      # Permission settings — defaultMode + allow/deny rules.
      # Doc: code.claude.com/docs/en/permission-modes. `bypassPermissions`
      # starts every session without prompts; the pro variant stays in
      # `default` for screen-share safety.
      permissions = {
        defaultMode = if outputStyle == "vex-pro" then "default" else "bypassPermissions";

        allow = [
          "mcp__claude_ai_MCPHub__search_tools"
          "mcp__claude_ai_MCPHub__describe_tool"
          "mcp__claude_ai_MCPHub__call_tool"
        ]
        ++ [
          "Bash(git log:*)"
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git remote:*)"
          "Bash(git fetch:*)"
          "Bash(git rev-parse:*)"
        ]
        ++ [
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(readlink:*)"
          "Bash(echo:*)"
          "Bash(which:*)"
          "Bash(file:*)"
          "Bash(wc:*)"
        ]
        ++ [
          "Bash(nix eval:*)"
          "Bash(nix build:*)"
          "Bash(nix-shell:*)"
          "Bash(nix flake:*)"
          "Bash(nixos-rebuild build:*)"
          "Bash(nh home:*)"
        ]
        ++ [
          "Bash(TZ='Australia/Melbourne' date:*)"
          "Bash(python3:*)"
          "Bash(node:*)"
          "Bash(npx:*)"
          "Bash(claude:*)"
          "Bash(curl:*)"
          "Bash(gh api:*)"
          "Bash(gh repo:*)"
          "Bash(gh release:*)"
        ]
        ++ [
          "Bash(gws gmail +triage:*)"
          "Bash(gws gmail +read:*)"
          "Bash(gws gmail users messages list:*)"
          "Bash(gws gmail users messages get:*)"
          "Bash(gws gmail users threads get:*)"
          "Bash(gws gmail users labels list:*)"
          "Bash(gws calendar:*)"
          "Bash(gws drive files list:*)"
        ]
        ++ [
          "WebSearch"
        ];

        deny = [
          "mcp__claude_ai_Google_Drive"
          "mcp__claude_ai_Atlassian"
          "mcp__claude_ai_Slack"
          "WebFetch"
        ];
      };

      disabledMcpjsonServers = [ "posthog" ];

      statusLine = claudeStatusLine;

      hooks = {
        PreCompact = [
          {
            hooks = [
              {
                type = "command";
                command = "cat ${hookDir}/compaction${hookSuffix}.md";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            hooks = [
              {
                type = "command";
                command = "cat ${hookDir}/session-end.md";
              }
            ];
          }
        ];
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "${cc-direnv-load}/bin/cc-direnv-load";
                timeout = 10;
              }
              {
                type = "command";
                command = "cat ${hookDir}/session-start${hookSuffix}.md";
              }
            ];
          }
          {
            matcher = "compact";
            hooks = [
              {
                type = "command";
                command = "${cc-direnv-load}/bin/cc-direnv-load";
                timeout = 10;
              }
              {
                type = "command";
                command = "cat ${hookDir}/session-reload${hookSuffix}.md && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
              }
            ];
          }
        ];
        CwdChanged = [
          {
            hooks = [
              {
                type = "command";
                command = "${cc-direnv-load}/bin/cc-direnv-load";
                timeout = 10;
              }
            ];
          }
        ];
        PostToolUse = [
          {
            matcher = "Edit|Write|MultiEdit";
            hooks = [
              {
                type = "command";
                command = "${cc-nix-lint}/bin/cc-nix-lint";
                timeout = 30;
              }
            ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = "${cc-restart-hook}/bin/cc-restart-hook";
                timeout = 5;
              }
            ];
          }
        ];
      };
    }
    // lib.optionalAttrs (model != null) {
      inherit model;
    };

  # Hand-built settings.json for the variant dirs (canonical .claude is module-managed).
  mkSettingsFile =
    {
      outputStyle,
      hookSuffix,
      hookDir ? "${aiSkills}/vex/hooks",
    }:
    pkgs.writeText "claude-code-settings-${outputStyle}.json" (
      builtins.toJSON (
        (mkSettingsContent { inherit outputStyle hookSuffix hookDir; })
        // {
          "$schema" = "https://json.schemastore.org/claude-code-settings.json";
        }
      )
    );

  plainSettingsFile = pkgs.writeText "claude-code-settings-plain.json" (
    builtins.toJSON {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      feedbackSurveyRate = 0;
      autoMemoryEnabled = false;
      env = claudeIdentityEnv;
      statusLine = claudeStatusLine;
    }
  );

  # Variant config dirs — kept on the manual home.file generator because the
  # programs.claude-code module is single-dir (~/.claude only). Activated via
  # CLAUDE_CONFIG_DIR or the ccp profile selector wrappers (see fish.nix aliases).
  baseVexClaudeContext = ''
    # Vex
    @vex/core.md
    @vex/output-style.md
    @vex/rules/brain.md
    @vex/rules/cli-routing.md
    @vex/rules/exec-function.md
    @vex/rules/interaction.md
    @vex/rules/protocols.md
    @vex/rules/shane-profile.md
  '';

  claudeCode48Context = "# Vex — Claude Code\n@vex/claude-code/core.md\n@vex/claude-code/operations.md\n";

  vexVariantDirs = [ ".claude-work" ];
  plainVariantDirs = [
    ".claude-pro"
    ".claude-pro-work"
  ];

  # ─── home.file generators for variant dirs only ────────────────────────
  filesForVexVariant =
    dir:
    let
      settingsSrc = mkSettingsFile {
        outputStyle = "vex";
        hookSuffix = "";
        hookDir = claudeVexStack;
      };
    in
    {
      "${dir}/settings.json" = {
        source = settingsSrc;
        force = true;
      };
      "${dir}/themes/vex.json".source = vexThemeFile;
      "${dir}/CLAUDE.md" = {
        text = claudeCode48Context;
        force = true;
      };
    }
    // {
      "${dir}/vex/core.md".source = "${aiSkills}/vex/core.md";
      "${dir}/vex/adapters/claude-code.md".source = "${aiSkills}/vex/adapters/claude-code.md";
      "${dir}/output-styles/vex.md".source = "${claudeVexStack}/output-style.md";
      "${dir}/rules".source = "${aiSkills}/vex/rules";
      "${dir}/agents".source = "${aiSkills}/vex/agents";
    }
    // {
      "${dir}/vex/claude-code" = {
        source = claudeVexStack;
        force = true;
      };
    }
    // (lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${dir}/skills/${name}" {
        inherit source;
        recursive = true;
      }
    ) globalSkillsAttrs);

  filesForPlainVariant = dir: {
    "${dir}/settings.json" = {
      source = plainSettingsFile;
      force = true;
    };
  };

in
{
  # ─── Canonical ~/.claude — home-manager module owns it ─────────────────
  programs.claude-code = {
    enable = true;

    # claude-code with tweakcc-fixed + lobotomized-claude-code system-prompt
    # overrides baked in at build time. See pkgs/claude-code-patched/.
    package = claude-code-patched;

    settings = mkSettingsContent {
      outputStyle = "vex";
      hookSuffix = "";
      model = "claude-opus-4-6[1m]";
    };

    context = baseVexClaudeContext;

    # Shared MCP servers come from programs.mcp.servers and are translated
    # into Claude Code's native mcpServers shape by the Home Manager module.
    enableMcpIntegration = true;

    # Plugins are NOT declared here — fully imperative via `/plugin`. Claude's
    # writable cache (~/.claude/plugins/*.json) is the sole source of truth.

    # Skills — only the always-use baseline. `recursive = true` makes
    # ~/.claude/skills a real directory whose nix-owned entries are the only
    # managed children, so a hand-dropped ~/.claude/skills/<scratch>/SKILL.md
    # loads and persists without a rebuild. Work/project packs are linked into
    # repo-local .agents/skills and .claude/skills manually.
    skills = globalSkillsAttrs;

    # Rules + agents dirs — module symlinks ~/.claude/{rules,agents}
    # recursively from the flake-input source.
    rulesDir = "${aiSkills}/vex/rules";
    agentsDir = "${aiSkills}/vex/agents";
  };

  home = {
    # claude-restart on PATH so the fish `claude` function (see fish.nix) can
    # find it, plus making it directly invokable as `claude-restart` for
    # debugging or use outside fish.
    packages = [
      claude-restart
      claude-work
      claude-plain
      claude-delegate
    ];

    # Two things the module doesn't expose options for, kept as raw home.file:
    # - themes/vex.json (no themes option in the module)
    # - output-styles/vex.md (programs.claude-code.outputStyles treats store-path
    #   strings as inline text; raw home.file keeps it as a real source file)
    # - vex/core.md at a custom path (referenced from CLAUDE.md as @vex/core.md)
    file = lib.foldl' lib.recursiveUpdate {
      ".claude/themes/vex.json".source = vexThemeFile;
      ".claude/output-styles/vex.md".source = "${aiSkills}/vex/output-style.md";
      ".claude/vex/core.md".source = "${aiSkills}/vex/core.md";
      ".claude/vex/output-style.md".source = "${aiSkills}/vex/output-style.md";
      ".claude/vex/rules".source = "${aiSkills}/vex/rules";
      ".claude/vex/claude-code" = {
        source = claudeVexStack;
        force = true;
      };
    } ((map filesForVexVariant vexVariantDirs) ++ (map filesForPlainVariant plainVariantDirs));

    activation.cleanPlainClaudeProfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      for dir in "$HOME/.claude-pro" "$HOME/.claude-pro-work"; do
        if [ ! -d "$dir" ]; then
          continue
        fi

        for rel in \
          CLAUDE.md \
          CLAUDE.md.backup \
          agents \
          agents.backup \
          output-styles/vex.md \
          output-styles/vex.md.backup \
          output-styles/vex-pro.md \
          output-styles/vex-pro.md.backup \
          rules \
          skills \
          themes/vex.json \
          themes/vex.json.backup \
          vex
        do
          target="$dir/$rel"
          if [ -e "$target" ] || [ -L "$target" ]; then
            $DRY_RUN_CMD rm -rf "$target"
          fi
        done

        for maybe_empty in themes output-styles; do
          target="$dir/$maybe_empty"
          if [ -d "$target" ] && [ -z "$(find "$target" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
            $DRY_RUN_CMD rmdir "$target"
          fi
        done
      done
    '';
  };
}
