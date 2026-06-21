{
  config,
  pkgs,
  lib,
  inputs,
  isLinux ? pkgs.stdenv.isLinux,
  ...
}:
let
  inherit (config.home) homeDirectory;

  aiSkills = inputs.ai-skills;
  tomlFormat = pkgs.formats.toml { };

  # ─── Helpers (mirrored from ../cc/default.nix) ─────────────────────────
  # Kept local rather than refactoring into a shared lib.nix so the cc
  # module's blast radius stays zero. Two helpers = ~20 lines; fine.
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

  mkSkillsAttrs =
    enumSrc: valueRoot:
    lib.listToAttrs (
      map (name: {
        inherit name;
        value = valueRoot + "/${name}";
      }) (lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir enumSrc)))
    );

  personalSkillsAttrs = mkSkillsAttrs "${aiSkills}/personal" "${aiSkills}/personal";

  # Keep the global skill surface deliberately small. Use repo-local
  # .agents/skills and .claude/skills symlinks for work/project packs.
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

  # ─── AGENTS.md concat (eval-time string) ───────────────────────────────
  # Codex's `programs.codex.context` types as `lines | path` — a derivation
  # output isn't either, so we build the persona as a single eval-time
  # string via builtins.readFile over the source files. The canonical
  # source stays in ai-skills/vex/; the concat is rebuilt automatically
  # when any rules/*.md file changes.
  #
  # Total size is ~39 KiB — exceeds the default project_doc_max_bytes (32
  # KiB), so we bump that in settings below.
  vexRuleFiles = lib.pipe "${aiSkills}/vex/rules" [
    builtins.readDir
    (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n))
    lib.attrNames
    (map (n: "${aiSkills}/vex/rules/${n}"))
  ];

  vexAgentsMd = lib.concatMapStringsSep "\n\n" builtins.readFile (
    [
      "${aiSkills}/vex/core.md"
      "${aiSkills}/vex/output-style.md"
      "${aiSkills}/vex/adapters/openai-codex.md"
    ]
    ++ vexRuleFiles
  );

  # ─── Hook scripts ──────────────────────────────────────────────────────
  # codex-emit-context: wrapper that wraps a markdown file's contents as the
  # hook-specific JSON shape Codex expects for context-injection events.
  # PreCompact/PostCompact do not support additionalContext in Codex 0.131.0.
  codex-emit-context = mkBashHook {
    name = "codex-emit-context";
    runtimeInputs = [ pkgs.jq ];
    script = ./codex-emit-context.sh;
  };

  # codex-nix-lint: PostToolUse hook that statix+deadnix-lints .nix files
  # touched by apply_patch. Emits blocking JSON feedback so codex
  # surfaces findings back to the model.
  codex-nix-lint = mkBashHook {
    name = "codex-nix-lint";
    runtimeInputs = [
      pkgs.jq
      pkgs.statix
      pkgs.deadnix
    ];
    script = ./codex-nix-lint.sh;
  };

  codexPackage = pkgs.codex-patched;

  codexConfigDir = ".codex";
  codexVariantDirs = [ ".codex-work" ];
  mutableCodexDirs = [ codexConfigDir ] ++ codexVariantDirs;

  codexMcpServer =
    name: server:
    let
      isHttp = (server.url or null) != null;
      alwaysStripKeys = [
        # Codex accepts bearer_token_env_var and headers, but rejects a literal
        # bearer_token even for HTTP transports.
        "bearer_token"
        "disabled"
        "headers"
        "type"
      ];
      stdioOnlyKeys = [
        "args"
        "command"
        "cwd"
        "env"
        "env_vars"
      ];
      httpOnlyKeys = [
        "bearer_token_env_var"
        "env_http_headers"
        "http_headers"
        "oauth"
        "oauth_resource"
        "url"
      ];
      transportKeys = if isHttp then stdioOnlyKeys else httpOnlyKeys;
      headers = server.headers or { };
    in
    (lib.filterAttrs (_: value: value != null) (
      lib.removeAttrs server (alwaysStripKeys ++ transportKeys)
    ))
    // (lib.optionalAttrs (isHttp && headers != { }) {
      http_headers = headers;
    })
    // {
      enabled = !(server.disabled or false);
    }
    // (lib.optionalAttrs (name == "aikido") {
      startup_timeout_sec = 30;
      tool_timeout_sec = 300;
    });

  transformedMcpServers = lib.optionalAttrs config.programs.mcp.enable (
    lib.mapAttrs codexMcpServer config.programs.mcp.servers
  );

  codexSettings = {
    # ─── Model ─────────────────────────────────────────────────────────
    # gpt-5.5 is the recommended default for ChatGPT Plus accounts —
    # newest frontier coding/agentic model, available on any tier when
    # signing in with ChatGPT. If 5.5 hasn't rolled to Shane's account
    # yet, fall back to "gpt-5.4" (also Plus-eligible). Note: avoid
    # `gpt-5.1-codex-max` and `gpt-5.3-codex-spark` — both gated to
    # ChatGPT Pro / Business / Enterprise plans, not Plus.
    # Override per-invocation with `codex --model <id>` or per-session
    # via the `/model` slash command in the TUI.
    model = "gpt-5.5";

    # ─── Persona cap ───────────────────────────────────────────────────
    # Default project_doc_max_bytes is 32 KiB; the concat'd Vex persona
    # is ~39 KiB. Bump to 64 KiB so AGENTS.md isn't truncated, with
    # headroom for the rules dir to grow.
    project_doc_max_bytes = 65536;

    # ─── Features ──────────────────────────────────────────────────────
    # Lifecycle hooks are feature-flagged off by default. Without this
    # the [hooks] block below is parsed but ignored.
    features.hooks = true;

    # ─── TUI ───────────────────────────────────────────────────────────
    # Codex's theme surface is syntax/diff highlighting, not a full
    # chrome skin like Claude Code's custom:vex theme. Pin Catppuccin
    # Mocha explicitly so terminals, NixVim, fzf, lazygit, tmux, and
    # Codex all line up around the same dark mauve aesthetic.
    tui = {
      theme = "catppuccin-mocha";
      status_line = [
        "model-with-reasoning"
        "project-name"
        "git-branch"
        "run-state"
        "context-remaining"
        "task-progress"
      ];
      terminal_title = [
        "activity"
        "project-name"
        "git-branch"
        "thread-title"
      ];
    };

    # ─── Subprocess environment inheritance ────────────────────────────
    # Codex defaults `shell_environment_policy.inherit = "core"` — a
    # minimal allow-list that strips XDG_RUNTIME_DIR, DBUS_SESSION_*,
    # WAYLAND_DISPLAY, and similar runtime vars. That breaks every CLI
    # wrapper here that shells out to `rbw get` (the agent socket lives
    # under $XDG_RUNTIME_DIR/rbw/) — including the xero MCP server and
    # any Bash tool call that fetches a token. Inheriting "all" mirrors
    # CC's default behaviour and lets the rbw-wrapped CLIs work cleanly.
    shell_environment_policy."inherit" = "all";

    # ─── Sandbox / approvals ───────────────────────────────────────────
    # Default to the fully trusted local-operator posture Shane wants:
    # no command prompts and no Codex sandbox. Opt out per session with:
    # `codex --sandbox workspace-write --ask-for-approval on-request`.
    sandbox_mode = "danger-full-access";
    approval_policy = "never";

    # ─── Project trust ────────────────────────────────────────────────
    # Codex tries to persist directory trust into config.toml during TUI
    # onboarding. The live file is mutable, but declare the baseline here
    # so fresh installs start trusted.
    projects."/home/shane/nix-config".trust_level = "trusted";

    # ─── Agents (subagent role table) ──────────────────────────────────
    # Keep concurrency conservative until we know how codex's subagent
    # orchestrator behaves with the Vex persona. Per-role agent
    # definitions are deferred — codex's `agents.<name>.config_file`
    # wants TOML role layers, not the CC-style .md agent files. Port
    # those individually in v2 once we've sat with the baseline.
    agents = {
      max_threads = 4;
      max_depth = 2;
    };

    # ─── Hooks ─────────────────────────────────────────────────────────
    # 8 events exist; we wire the two that matter most for parity:
    # - SessionStart: inject vex/hooks/session-start.md as context
    # - PostToolUse @ apply_patch: nix-lint .nix file edits
    hooks = {
      SessionStart = [
        {
          hooks = [
            {
              type = "command";
              command = "${codex-emit-context}/bin/codex-emit-context SessionStart ${aiSkills}/vex/hooks/session-start.md";
              timeout = 10;
            }
          ];
        }
      ];

      PostToolUse = [
        {
          matcher = "apply_patch";
          hooks = [
            {
              type = "command";
              command = "${codex-nix-lint}/bin/codex-nix-lint";
              timeout = 30;
            }
          ];
        }
      ];
    };
  }
  // lib.optionalAttrs (transformedMcpServers != { }) {
    mcp_servers = transformedMcpServers;
  };

  codexConfigSeed = tomlFormat.generate "codex-config.toml" codexSettings;
  codexHooksConfigSeed = tomlFormat.generate "codex-hooks-config.toml" {
    inherit (codexSettings) hooks;
  };
  codexMcpConfigSeed = tomlFormat.generate "codex-mcp-config.toml" {
    mcp_servers = transformedMcpServers;
  };

  filesForVariant =
    dir:
    {
      "${dir}/AGENTS.md".text = vexAgentsMd;
    }
    // lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${dir}/skills/${name}" {
        inherit source;
        recursive = true;
      }
    ) globalSkillsAttrs;

  mutableConfigActivation =
    dir:
    let
      configPath = "${homeDirectory}/${dir}/config.toml";
      rulesPath = "${homeDirectory}/${dir}/rules/default.rules";
    in
    ''
            $DRY_RUN_CMD mkdir -p "${homeDirectory}/${dir}/rules"

            if [ -L "${configPath}" ]; then
              $DRY_RUN_CMD rm "${configPath}"
            fi
            if [ ! -e "${configPath}" ]; then
              $DRY_RUN_CMD cp "${codexConfigSeed}" "${configPath}"
              $DRY_RUN_CMD chmod u+w "${configPath}"
            fi
            if [ -e "${configPath}" ]; then
              tmp="$(${pkgs.coreutils}/bin/mktemp)"
              ${pkgs.gawk}/bin/awk '
                /^\[\[hooks\.(SessionStart|PostToolUse|PreCompact)(\.hooks)?\]\]$/ { skip = 1; next }
                /^\[hooks\.state\.".*:(session_start|post_tool_use|pre_compact):[^"]*"\]$/ { skip = 1; next }
                /^\[/ { skip = 0 }
                !skip { print }
              ' "${configPath}" > "$tmp"
              $DRY_RUN_CMD cp "$tmp" "${configPath}"
              $DRY_RUN_CMD rm "$tmp"
              if [ -z "''${DRY_RUN_CMD:-}" ]; then
                printf '\n' >> "${configPath}"
                cat "${codexHooksConfigSeed}" >> "${configPath}"
                ${pkgs.python3}/bin/python - "${configPath}" <<'PY'
      import hashlib
      import json
      import pathlib
      import sys
      import tomllib

      config_path = pathlib.Path(sys.argv[1])
      config = tomllib.loads(config_path.read_text())
      event_labels = {
          "SessionStart": "session_start",
          "PostToolUse": "post_tool_use",
      }


      def hook_hash(event_label, group, handler):
          identity = {
              "event_name": event_label,
              "hooks": [
                  {
                      "async": handler.get("async", False),
                      "command": handler["command"],
                      "timeout": handler.get("timeout", 600),
                      "type": "command",
                  }
              ],
          }
          if group.get("matcher") is not None:
              identity["matcher"] = group["matcher"]
          payload = json.dumps(identity, sort_keys=True, separators=(",", ":")).encode()
          return "sha256:" + hashlib.sha256(payload).hexdigest()


      with config_path.open("a") as fh:
          fh.write("\n")
          for event_name, event_label in event_labels.items():
              for group_index, group in enumerate(config.get("hooks", {}).get(event_name, [])):
                  for handler_index, handler in enumerate(group.get("hooks", [])):
                      if handler.get("type") != "command":
                          continue
                      key = f"{config_path}:{event_label}:{group_index}:{handler_index}"
                      fh.write(f'[hooks.state."{key}"]\n')
                      fh.write(f'trusted_hash = "{hook_hash(event_label, group, handler)}"\n\n')
      PY
              else
                $DRY_RUN_CMD append managed hooks to "${configPath}"
              fi
            fi
            ${lib.optionalString (transformedMcpServers != { }) ''
              if [ -e "${configPath}" ]; then
                tmp="$(${pkgs.coreutils}/bin/mktemp)"
                ${pkgs.gawk}/bin/awk '
                  /^\[mcp_servers(\.|])/{ skip = 1; next }
                  /^\[/{ skip = 0 }
                  !skip{ print }
                ' "${configPath}" > "$tmp"
                $DRY_RUN_CMD cp "$tmp" "${configPath}"
                $DRY_RUN_CMD rm "$tmp"
                if [ -z "''${DRY_RUN_CMD:-}" ]; then
                  printf '\n' >> "${configPath}"
                  cat "${codexMcpConfigSeed}" >> "${configPath}"
                else
                  $DRY_RUN_CMD append managed mcp_servers to "${configPath}"
                fi
              fi
            ''}

            if [ -L "${rulesPath}" ]; then
              $DRY_RUN_CMD rm "${rulesPath}"
            fi
            if [ ! -e "${rulesPath}" ]; then
              $DRY_RUN_CMD cp "${./default.rules}" "${rulesPath}"
              $DRY_RUN_CMD chmod u+w "${rulesPath}"
            fi
    '';
in
{
  home = {
    # Variant CODEX_HOME dirs mirror the Claude Code CLAUDE_CONFIG_DIR pattern.
    # Auth stays mutable and unmanaged; run `CODEX_HOME=$HOME/.codex-work codex
    # login` once to bind this dir to the work account.
    file = lib.foldl' lib.recursiveUpdate { } (map filesForVariant codexVariantDirs);

    # Home Manager still owns the immutable parts (package, AGENTS.md, skills).
    # `config.toml` and `rules/default.rules` are writable user state seeded
    # from Nix on first activation, mirroring Home Manager's mutable settings
    # pattern for apps that write back into their own config.
    activation.codexMutableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatMapStringsSep "\n" mutableConfigActivation mutableCodexDirs
    );
  };

  programs = {
    codex = {
      enable = true;
      package = codexPackage;

      # ─── Persona ─────────────────────────────────────────────────────────
      # Single AGENTS.md concatenated from core.md + output-style + rules/.
      # Written to CODEX_HOME/AGENTS.md by the module.
      context = vexAgentsMd;

      # ─── Skills ──────────────────────────────────────────────────────────
      # Global skills stay tiny; project/use-case skills live under repo-local
      # .agents/skills and .claude/skills symlinks back to ~/ai-skills.
      skills = globalSkillsAttrs;

      # ─── Rules (prefix_rule allow-list) ──────────────────────────────────
      # Mutable runtime files are seeded below instead of managed through
      # `programs.codex.settings` / `programs.codex.rules`, because Codex
      # legitimately persists approvals and preferences into those files.
      settings = { };
      rules = { };
    };
  }
  // lib.optionalAttrs isLinux {
    codexDesktopLinux = {
      enable = true;

      # The community wrapper auto-stages the Chrome native host. Phone access
      # needs the experimental Linux mobile-control variant plus an app-server
      # user service; keep Computer Use UI off until we know we need it.
      remoteMobileControl.enable = true;
      remoteControl = {
        enable = true;
        package = codexPackage;
        codexHome = "${homeDirectory}/${codexConfigDir}";
      };
    };
  };
}
