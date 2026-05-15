{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  shared = import ../mcp {
    inherit pkgs config;
    homeDirectory = config.home.homeDirectory;
  };
  allMcpServers = shared.mcpServers;

  # Private values (work URLs / email attributes) live in the companion
  # nix-config-private flake input. The public flake stays clean.
  priv = inputs.nix-config-private.values;

  # Symlink-to-mutable-path helper for everything sourced from ~/ai-skills/.
  # Files propagate live without rebuild — edit core.md, hot-reload in CC.
  # Note: flake eval is pure, so we cannot pathExists-guard external paths.
  # If ~/ai-skills/ is missing on a fresh machine the symlinks will be broken
  # until the repo is cloned — CC tolerates this gracefully.
  link = config.lib.file.mkOutOfStoreSymlink;
  homeDir = config.home.homeDirectory;
  aiSkills = "${homeDir}/ai-skills";

  vexThemeFile = ./vex-theme.json;

  # Themed status line — invoked by CC via settings.json statusLine.command.
  vex-statusline = pkgs.writeShellApplication {
    name = "vex-statusline";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 ${./vex-statusline.py}
    '';
  };

  # SessionStart / CwdChanged hook: load direnv environment into CLAUDE_ENV_FILE.
  cc-direnv-load = pkgs.writeShellApplication {
    name = "cc-direnv-load";
    runtimeInputs = [
      pkgs.direnv
      pkgs.bash
    ];
    text = ''
      exec bash ${./cc-direnv-load.sh}
    '';
  };

  # Settings JSON builder — parameterised so we produce both the intimate Vex
  # variant (used by ~/.claude and ~/.claude-work) and the public-safe Vex (Pro)
  # variant (used by ~/.claude-pro).
  mkSettings =
    {
      outputStyle,
      hookSuffix,
    }:
    pkgs.writeText "claude-code-settings-${outputStyle}.json" (
      builtins.toJSON ({
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";
        theme = "custom:vex";
        outputStyle = outputStyle;
        skipDangerousModePermissionPrompt = true;
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
            "Dreaming"
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

        env = {
          CLAUDE_CODE_ENABLE_TELEMETRY = "1";
          OTEL_METRICS_EXPORTER = "otlp";
          OTEL_LOGS_EXPORTER = "otlp";
          OTEL_EXPORTER_OTLP_ENDPOINT = priv.otelEndpoint;
          OTEL_EXPORTER_OTLP_PROTOCOL = "http/json";
          OTEL_RESOURCE_ATTRIBUTES = "autograb_user=${priv.autograbUser},team=${priv.autograbTeam}";
        };

        permissions.allow =
          # MCP — MCPHub smart routing
          [
            "mcp__claude_ai_MCPHub__search_tools"
            "mcp__claude_ai_MCPHub__describe_tool"
            "mcp__claude_ai_MCPHub__call_tool"
          ]
          ++
            # Bash — git (read-only)
            [
              "Bash(git log:*)"
              "Bash(git status:*)"
              "Bash(git diff:*)"
              "Bash(git show:*)"
              "Bash(git branch:*)"
              "Bash(git remote:*)"
              "Bash(git fetch:*)"
              "Bash(git rev-parse:*)"
            ]
          ++
            # Bash — filesystem (read-only)
            [
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
          ++
            # Bash — nix (non-destructive)
            [
              "Bash(nix eval:*)"
              "Bash(nix build:*)"
              "Bash(nix-shell:*)"
              "Bash(nix flake:*)"
              "Bash(nixos-rebuild build:*)"
              "Bash(nh home:*)"
            ]
          ++
            # Bash — tools
            [
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
          ++
            # Bash — Google Workspace (read-only)
            [
              "Bash(gws gmail +triage:*)"
              "Bash(gws gmail +read:*)"
              "Bash(gws gmail users messages list:*)"
              "Bash(gws gmail users messages get:*)"
              "Bash(gws gmail users threads get:*)"
              "Bash(gws gmail users labels list:*)"
              "Bash(gws calendar:*)"
              "Bash(gws drive files list:*)"
            ]
          ++
            # Web
            [
              "WebSearch"
              "WebFetch"
            ];

        disabledMcpjsonServers = [ "posthog" ];

        # Deny cloud MCP connectors retired in favour of CLIs. The tools still
        # appear in the deferred tool list (claude.ai-managed), but Claude Code
        # blocks any attempt to call them.
        permissions.deny = [
          "mcp__claude_ai_Google_Drive"
          "mcp__claude_ai_Atlassian"
          "mcp__claude_ai_Slack"
        ];

        statusLine = {
          type = "command";
          command = "${vex-statusline}/bin/vex-statusline";
        };

        hooks = {
          PreCompact = [
            {
              hooks = [
                {
                  type = "command";
                  command = "cat $HOME/ai-skills/vex/hooks/compaction${hookSuffix}.md";
                }
              ];
            }
          ];
          SessionEnd = [
            {
              hooks = [
                {
                  type = "command";
                  command = "cat $HOME/ai-skills/vex/hooks/session-end.md";
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
                  command = "cat $HOME/ai-skills/vex/hooks/session-start${hookSuffix}.md";
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
                  command = "cat $HOME/ai-skills/vex/hooks/session-reload${hookSuffix}.md && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
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
        };
      })
    );

  settingsJson = mkSettings {
    outputStyle = "vex";
    hookSuffix = "";
  };
  settingsJsonPro = mkSettings {
    outputStyle = "vex-pro";
    hookSuffix = "-pro";
  };

  vexConfigDirs = [
    ".claude"
    ".claude-work"
  ];
  proConfigDirs = [
    ".claude-pro"
  ];
  allConfigDirs = vexConfigDirs ++ proConfigDirs;

  # ─── ag-ai-skills bake-in ──────────────────────────────────────────────
  # install.sh resolves shared_refs from SKILL.md frontmatter into per-skill
  # references/ dirs. We run it once at build time inside a derivation; the
  # resulting per-skill subdirs are then symlinked into each CC config dir
  # via home.file below.
  agSkillsSrc = inputs.ag-ai-skills;
  # install.sh isn't committed to ag-ai-skills upstream yet — vendor a copy
  # alongside this module. Once upstream commits it, we can drop the cp and
  # use the in-tree script directly.
  agSkillsInstallScript = ./install-ag-ai-skills.sh;
  agSkillsBuilt = pkgs.stdenv.mkDerivation {
    pname = "ag-ai-skills-built";
    version = "0";
    src = agSkillsSrc;
    nativeBuildInputs = [
      pkgs.yq-go
      pkgs.bash
    ];
    dontConfigure = true;
    dontInstall = true;
    buildPhase = ''
      runHook preBuild
      cp ${agSkillsInstallScript} ./install.sh
      mkdir -p $out
      bash ./install.sh "$out"
      runHook postBuild
    '';
  };
  workSkillNames = lib.attrNames (
    lib.filterAttrs (_: t: t == "directory") (builtins.readDir "${agSkillsSrc}/skills")
  );

  # ─── home.file generator per config dir + variant ──────────────────────
  filesForDir =
    {
      dir,
      variant,
    }:
    let
      isVex = variant == "vex";
      settingsSrc = if isVex then settingsJson else settingsJsonPro;
      personaPath = if isVex then "${aiSkills}/vex/core.md" else "${aiSkills}/vex/core-pro.md";
      personaTarget = if isVex then "vex/core.md" else "vex/core-pro.md";
      stylePath =
        if isVex then "${aiSkills}/vex/output-style.md" else "${aiSkills}/vex/output-style-pro.md";
      styleTarget = if isVex then "output-styles/vex.md" else "output-styles/vex-pro.md";
      claudeMd = if isVex then "# Vex\n@vex/core.md\n" else "# Vex (Pro)\n@vex/core-pro.md\n";
    in
    # Static files (independent of ai-skills clone state)
    {
      "${dir}/settings.json".source = settingsSrc;
      "${dir}/themes/vex.json".source = vexThemeFile;
      "${dir}/CLAUDE.md".text = claudeMd;
    }
    # Personal vex content — live-symlinks to ~/ai-skills/vex/ (mutable repo).
    # Single-symlink for rules/ + agents/ dirs (no per-file iteration needed,
    # CC walks the symlinked dir at runtime).
    // {
      "${dir}/${personaTarget}".source = link personaPath;
      "${dir}/${styleTarget}".source = link stylePath;
      "${dir}/rules".source = link "${aiSkills}/vex/rules";
      "${dir}/agents".source = link "${aiSkills}/vex/agents";
    }
    # Work skills — baked via install.sh derivation (shared_refs resolved),
    # symlinked per-skill from the nix store path
    // lib.listToAttrs (
      map (name: {
        name = "${dir}/skills/${name}";
        value = {
          source = "${agSkillsBuilt}/${name}";
          recursive = true;
        };
      }) workSkillNames
    );
in
{
  programs.claude-code.enable = true;

  home.file = lib.foldl' lib.recursiveUpdate { } (
    (map (
      dir:
      filesForDir {
        inherit dir;
        variant = "vex";
      }
    ) vexConfigDirs)
    ++ (map (
      dir:
      filesForDir {
        inherit dir;
        variant = "vex-pro";
      }
    ) proConfigDirs)
  );

  # Personal skills — per-name symlinks to ~/ai-skills/personal/<name> alongside
  # the work skills deployed via home.file. Kept as activation because we need
  # to iterate at runtime (mutable dir, fresh-machine-tolerant) and they share
  # the .claude/skills/ namespace with home-manager-managed work skills.
  home.activation.claudeCodePersonalSkills =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for dir in ${lib.concatStringsSep " " (map (d: "$HOME/${d}") allConfigDirs)}; do
        SKILLS_DIR="$dir/skills"
        $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"
        if [ -d "$HOME/ai-skills/personal" ]; then
          for skill in "$HOME/ai-skills/personal"/*/; do
            [ -d "$skill" ] || continue
            name=$(basename "$skill")
            $DRY_RUN_CMD ln -sfn "$skill" "$SKILLS_DIR/$name"
          done
        fi
      done
    '';

  # ~/.claude.json is mutable runtime state (auth tokens, recent sessions, …).
  # We merge our mcpServers attrset into it via jq, preserving everything else.
  # The other legitimately-shell-shaped activation that survives the refactor.
  home.activation.claudeCodeMcpServers =
    let
      allServersJson = builtins.toJSON allMcpServers;
      defaultJson = builtins.toJSON { mcpServers = allMcpServers; };
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CLAUDE_JSON="$HOME/.claude.json"
      if [ -f "$CLAUDE_JSON" ]; then
        $DRY_RUN_CMD ${pkgs.jq}/bin/jq --argjson servers '${allServersJson}' \
          '.mcpServers = $servers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
          && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        $DRY_RUN_CMD echo '${defaultJson}' > "$CLAUDE_JSON"
      fi
      rm -f "$HOME/.mcp.json"
    '';
}
