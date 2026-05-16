{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  shared = import ../mcp { inherit pkgs; };
  allMcpServers = shared.mcpServers;

  # Private values (work URLs / email attributes) live in the companion
  # nix-config-private flake input. The public flake stays clean.
  priv = inputs.nix-config-private.values;

  # Vex persona + personal skills come from the ai-skills flake input (private
  # GitHub repo). Edits go via: change ai-skills repo → commit → nix flake
  # update ai-skills → rebuild. For active iteration use `nrs-iter` which
  # `--override-input`s this to ~/ai-skills (commits not even required).
  aiSkills = inputs.ai-skills;

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

  # Themed status line — invoked by CC via settings.json statusLine.command.
  # Stays on writeShellApplication rather than writers.writePython3Bin
  # because the latter runs pycodestyle and our script (intentionally) has
  # long lines and a non-PEP8 shebang-as-comment.
  vex-statusline = pkgs.writeShellApplication {
    name = "vex-statusline";
    runtimeInputs = [ pkgs.python3 ];
    text = ''exec python3 ${./vex-statusline.py}'';
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
  # function that calls this binary, so `cc`/`ccr`/`ccw`/`ccp` abbrs all
  # route through it. Inside the wrapper, `command -v claude` resolves to
  # the home-manager-wrapped binary cleanly (fish function shadowing
  # doesn't propagate to bash).
  claude-restart = mkBashHook {
    name = "claude-restart";
    script = ./claude-restart-wrapper.sh;
  };

  # UserPromptSubmit hook for claude-restart: intercepts the literal word
  # `restart` (trimmed, case-insensitive), touches the per-wrapper flag,
  # SIGTERMs claude, and blocks the prompt from reaching the model.
  cc-restart-hook = mkBashHook {
    name = "cc-restart-hook";
    runtimeInputs = [ pkgs.jq ];
    script = ./restart-hook.sh;
  };

  # ─── Plugin / marketplace pins ─────────────────────────────────────────
  # Marketplace clone — discord, frontend-design live inside it as subdirs.
  # Bump rev + hash to update. nix-prefetch-url --unpack <tarball> gives the
  # base32 hash; nix-hash --to-sri --type sha256 <hash> converts to SRI.
  claudePluginsMarketplace = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "1a2f18b05cf5652fd25403e8d229fc884fb84103";
    hash = "sha256-LjMusufv+H8+t2O9DJgRS9QOuHelepIWuWFqiK5y3UQ=";
  };
  aikidoPlugin = pkgs.fetchFromGitHub {
    owner = "AikidoSec";
    repo = "aikido-claude-plugin";
    rev = "5d9c13d367218e9b43a11d4502f623ab98859225";
    hash = "sha256-tukG/k82QKFe0ruGVkIXZpt2qXs1KMz5mnyXnflJo8I=";
  };

  # Single source of truth for CC plugins — used to derive both
  # programs.claude-code.plugins (--plugin-dir wrapper args) AND
  # settings.json#enabledPlugins (marketplace registry state, so `claude plugin
  # list` shows them as enabled). Add a new plugin here and both surfaces update.
  ccPlugins = {
    "aikido@claude-plugins-official" = aikidoPlugin;
    "discord@claude-plugins-official" = "${claudePluginsMarketplace}/external_plugins/discord";
    "frontend-design@claude-plugins-official" = "${claudePluginsMarketplace}/plugins/frontend-design";
  };

  # ─── ag-ai-skills bake-in ──────────────────────────────────────────────
  # install.sh resolves shared_refs from SKILL.md frontmatter into per-skill
  # references/ dirs. We run it once at build time inside a derivation; the
  # resulting per-skill subdirs are then handed to programs.claude-code.skills
  # for the canonical .claude dir, and inlined via home.file for the variants.
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
  # ─── ai-skills (personal skills + vex persona) ─────────────────────────
  # Personal skills are directories under ai-skills/personal/. Enumerated at
  # eval time from the flake input — replaces the runtime-iteration activation
  # script that used to walk ~/ai-skills/personal/ at switch time.
  #
  # Helper: enumerate subdirectory names in `enumSrc` and map each to a
  # value under `valueRoot`. Used for both work skills (enum source =
  # ag-ai-skills source, value root = the post-install derivation) and
  # personal skills (enum source = value root = the personal/ dir).
  mkSkillsAttrs =
    enumSrc: valueRoot:
    lib.listToAttrs (
      map (name: {
        inherit name;
        value = "${valueRoot}/${name}";
      }) (lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir enumSrc)))
    );

  workSkillsAttrs = mkSkillsAttrs "${agSkillsSrc}/skills" agSkillsBuilt;
  personalSkillsAttrs = mkSkillsAttrs "${aiSkills}/personal" "${aiSkills}/personal";
  allSkillsAttrs = workSkillsAttrs // personalSkillsAttrs;

  workSkillNames = lib.attrNames workSkillsAttrs;
  personalSkillNames = lib.attrNames personalSkillsAttrs;

  # ─── claude-code-patched ───────────────────────────────────────────────
  # pkgs.claude-code with tweakcc-fixed applied at build time + skrabe's
  # lobotomized-claude-code system-prompt overrides baked in. The patched
  # binary is its own /nix/store derivation — survives GC, no sudo/re-apply
  # dance, nh switch re-derives when either input bumps. Knobs in
  # packages/claude-code-patched/config.json.
  tweakcc-fixed = pkgs.callPackage ./packages/tweakcc-fixed.nix { };
  claude-code-patched = pkgs.callPackage ./packages/claude-code-patched { inherit tweakcc-fixed; };

  # ─── Settings content ──────────────────────────────────────────────────
  # Shape parameterised so we produce both the intimate Vex variant (canonical
  # ~/.claude managed by programs.claude-code module + ~/.claude-work variant)
  # and the public-safe Vex (Pro) variant (~/.claude-pro).
  mkSettingsContent =
    {
      outputStyle,
      hookSuffix,
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

      # Marketplace registry state — without this, plugins loaded via
      # --plugin-dir show as 'disabled' in `claude plugin list`.
      enabledPlugins = lib.mapAttrs (_: _: true) ccPlugins;

      env = {
        CLAUDE_CODE_ENABLE_TELEMETRY = "1";
        OTEL_METRICS_EXPORTER = "otlp";
        OTEL_LOGS_EXPORTER = "otlp";
        OTEL_EXPORTER_OTLP_ENDPOINT = priv.otelEndpoint;
        OTEL_EXPORTER_OTLP_PROTOCOL = "http/json";
        OTEL_RESOURCE_ATTRIBUTES = "autograb_user=${priv.autograbUser},team=${priv.autograbTeam}";
      };

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
          "WebFetch"
        ];

        deny = [
          "mcp__claude_ai_Google_Drive"
          "mcp__claude_ai_Atlassian"
          "mcp__claude_ai_Slack"
        ];
      };

      disabledMcpjsonServers = [ "posthog" ];

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
                command = "cat ${aiSkills}/vex/hooks/compaction${hookSuffix}.md";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            hooks = [
              {
                type = "command";
                command = "cat ${aiSkills}/vex/hooks/session-end.md";
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
                command = "cat ${aiSkills}/vex/hooks/session-start${hookSuffix}.md";
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
                command = "cat ${aiSkills}/vex/hooks/session-reload${hookSuffix}.md && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
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
    };

  # Hand-built settings.json for the variant dirs (canonical .claude is module-managed).
  mkSettingsFile =
    {
      outputStyle,
      hookSuffix,
    }:
    pkgs.writeText "claude-code-settings-${outputStyle}.json" (
      builtins.toJSON (
        (mkSettingsContent { inherit outputStyle hookSuffix; })
        // {
          "$schema" = "https://json.schemastore.org/claude-code-settings.json";
        }
      )
    );

  # Variant config dirs — kept on the manual home.file generator because the
  # programs.claude-code module is single-dir (~/.claude only). Activated via
  # CLAUDE_CONFIG_DIR=$HOME/.claude-work claude (see fish.nix aliases).
  vexVariantDirs = [ ".claude-work" ];
  proVariantDirs = [ ".claude-pro" ];

  # ─── home.file generator for variant dirs only ─────────────────────────
  filesForVariant =
    {
      dir,
      variant,
    }:
    let
      isVex = variant == "vex";
      settingsSrc =
        if isVex then
          mkSettingsFile {
            outputStyle = "vex";
            hookSuffix = "";
          }
        else
          mkSettingsFile {
            outputStyle = "vex-pro";
            hookSuffix = "-pro";
          };
      personaTarget = if isVex then "vex/core.md" else "vex/core-pro.md";
      styleTarget = if isVex then "output-styles/vex.md" else "output-styles/vex-pro.md";
      claudeMd = if isVex then "# Vex\n@vex/core.md\n" else "# Vex (Pro)\n@vex/core-pro.md\n";
    in
    {
      "${dir}/settings.json".source = settingsSrc;
      "${dir}/themes/vex.json".source = vexThemeFile;
      "${dir}/CLAUDE.md".text = claudeMd;
    }
    // {
      "${dir}/${personaTarget}".source = "${aiSkills}/${personaTarget}";
      "${dir}/${styleTarget}".source =
        if isVex then "${aiSkills}/vex/output-style.md" else "${aiSkills}/vex/output-style-pro.md";
      "${dir}/rules".source = "${aiSkills}/vex/rules";
      "${dir}/agents".source = "${aiSkills}/vex/agents";
    }
    // lib.listToAttrs (
      (map (name: {
        name = "${dir}/skills/${name}";
        value = {
          source = "${agSkillsBuilt}/${name}";
          recursive = true;
        };
      }) workSkillNames)
      ++ (map (name: {
        name = "${dir}/skills/${name}";
        value = {
          source = "${aiSkills}/personal/${name}";
          recursive = true;
        };
      }) personalSkillNames)
    );

in
{
  # claude-restart on PATH so the fish `claude` function (see fish.nix) can
  # find it, plus making it directly invokable as `claude-restart` for
  # debugging or use outside fish.
  home.packages = [ claude-restart ];

  # ─── Canonical ~/.claude — home-manager module owns it ─────────────────
  programs.claude-code = {
    enable = true;

    # claude-code with tweakcc-fixed + lobotomized-claude-code system-prompt
    # overrides baked in at build time. See ./packages/claude-code-patched/.
    package = claude-code-patched;

    settings = mkSettingsContent {
      outputStyle = "vex";
      hookSuffix = "";
    };

    context = "# Vex\n@vex/core.md\n";

    # MCP servers are bundled into a synthetic plugin dir + injected via
    # --plugin-dir on the wrapped `claude` binary. Nothing touches ~/.claude.json.
    mcpServers = allMcpServers;

    # Marketplaces — writes both settings.json#extraKnownMarketplaces and
    # ~/.claude/plugins/known_marketplaces.json declaratively.
    marketplaces = {
      claude-plugins-official = claudePluginsMarketplace;
    };

    # Plugins — wrapped binary auto-loads each via --plugin-dir. discord and
    # frontend-design live inside the marketplace clone; aikido is its own
    # upstream repo. See `ccPlugins` above for the single source of truth.
    plugins = lib.attrValues ccPlugins;

    # Skills — work (from ag-ai-skills) + personal (from ai-skills/personal/).
    # Module symlinks each into .claude/skills/<name>/.
    skills = allSkillsAttrs;

    # Vex output style — module writes ~/.claude/output-styles/vex.md.
    outputStyles.vex = "${aiSkills}/vex/output-style.md";

    # Rules + agents dirs — module symlinks ~/.claude/{rules,agents}
    # recursively from the flake-input source.
    rulesDir = "${aiSkills}/vex/rules";
    agentsDir = "${aiSkills}/vex/agents";
  };

  # Two things the module doesn't expose options for, kept as raw home.file:
  # - themes/vex.json (no themes option in the module)
  # - vex/core.md at a custom path (referenced from CLAUDE.md as @vex/core.md)
  home.file =
    lib.foldl' lib.recursiveUpdate
      {
        ".claude/themes/vex.json".source = vexThemeFile;
        ".claude/vex/core.md".source = "${aiSkills}/vex/core.md";
      }
      (
        (map (
          dir:
          filesForVariant {
            inherit dir;
            variant = "vex";
          }
        ) vexVariantDirs)
        ++ (map (
          dir:
          filesForVariant {
            inherit dir;
            variant = "vex-pro";
          }
        ) proVariantDirs)
      );
}
