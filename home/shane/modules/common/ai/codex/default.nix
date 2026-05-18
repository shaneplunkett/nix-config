{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (config.home) homeDirectory;

  aiSkills = inputs.ai-skills;
  agSkillsSrc = inputs.ag-ai-skills;
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

  # ─── ag-ai-skills bake-in ──────────────────────────────────────────────
  # Mirrors the cc/default.nix derivation — install.sh resolves shared_refs
  # from SKILL.md frontmatter at build time. The script is vendored from
  # the cc module (single source).
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
      cp ${../cc/install-ag-ai-skills.sh} ./install.sh
      mkdir -p $out
      bash ./install.sh "$out"
      find "$out" -name SKILL.md -exec sed -i '1s/^-----$/---/' {} +
      runHook postBuild
    '';
  };

  workSkillsAttrs = mkSkillsAttrs "${agSkillsSrc}/skills" agSkillsBuilt;
  personalSkillsAttrs = mkSkillsAttrs "${aiSkills}/personal" "${aiSkills}/personal";
  allSkillsAttrs = workSkillsAttrs // personalSkillsAttrs;

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
    ]
    ++ vexRuleFiles
  );

  # ─── Hook scripts ──────────────────────────────────────────────────────
  # codex-emit-context: generic wrapper that wraps a markdown file's
  # contents as the JSON output schema codex expects for context-injection
  # hook events. Used by SessionStart / PreCompact to inject vex/hooks/*.md
  # content as additionalContext.
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

  # ─── codex-desktop-linux (NixOS GUI) ───────────────────────────────────
  # Linux GUI is community-packaged at ilysenko/codex-desktop-linux. It
  # extracts the official macOS Codex.dmg and re-shims it for Linux
  # Electron — same persistent.oaistatic.com payload the cask grabs.
  # Reads the same ~/.codex/{config.toml,AGENTS.md,skills,rules} this
  # module manages.
  #
  # CURRENTLY GATED OFF: upstream's payload FOD (codex-desktop-payload)
  # has a hash mismatch on Shane's hardware vs the maintainer's declared
  # SHA. The build runs for ~8 min in fixupPhase then errors with
  # `sha256-3/gGqIvT… (specified) vs sha256-CpDmuIOmr4j… (got)` —
  # reproducibility leak in the asar/electron patch pipeline. File an
  # issue at github.com/ilysenko/codex-desktop-linux/issues/new before
  # flipping `enableLinuxGui = true` below. CLI (`pkgs.codex`) is
  # unaffected and works regardless.
  enableLinuxGui = false;
  codexDesktopLinux = inputs.codex-desktop-linux.packages.${pkgs.system}.default;
  codexPackage = pkgs.codex.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./patches/codex-vex-markdown-colours.patch
    ];
  });

  codexConfigDir = ".codex";
  codexVariantDirs = [ ".codex-work" ];
  mutableCodexDirs = [ codexConfigDir ] ++ codexVariantDirs;

  transformedMcpServers = lib.optionalAttrs config.programs.mcp.enable (
    lib.mapAttrs (
      _name: server:
      (lib.removeAttrs server [
        "disabled"
        "headers"
      ])
      // (lib.optionalAttrs (server ? headers && !(server ? http_headers)) {
        http_headers = server.headers;
      })
      // {
        enabled = !(server.disabled or false);
      }
    ) config.programs.mcp.servers
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
    # 8 events exist; we wire the three that matter most for parity:
    # - SessionStart: inject vex/hooks/session-start.md as context
    # - PreCompact: persona-preservation reminders before history compaction
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

      PreCompact = [
        {
          hooks = [
            {
              type = "command";
              command = "${codex-emit-context}/bin/codex-emit-context PreCompact ${aiSkills}/vex/hooks/compaction.md";
              timeout = 5;
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
    ) allSkillsAttrs;

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
    # Linux gets the community-built GUI (when enabled); darwin gets the
    # official cask via modules/darwin/homebrew.nix. macOS server
    # (homemacserver.nix) skips both since common/ai isn't imported there.
    packages = lib.optionals (pkgs.stdenv.isLinux && enableLinuxGui) [
      codexDesktopLinux
    ];

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

  programs.codex = {
    enable = true;
    package = codexPackage;

    # ─── Persona ─────────────────────────────────────────────────────────
    # Single AGENTS.md concatenated from core.md + output-style + rules/.
    # Written to CODEX_HOME/AGENTS.md by the module.
    context = vexAgentsMd;

    # ─── Skills ──────────────────────────────────────────────────────────
    # Same attrset CC consumes — module symlinks each into
    # CODEX_HOME/skills/<name>/. Work skills come from the post-install
    # derivation; personal skills come straight from the flake input.
    skills = allSkillsAttrs;

    # ─── Rules (prefix_rule allow-list) ──────────────────────────────────
    # Mutable runtime files are seeded below instead of managed through
    # `programs.codex.settings` / `programs.codex.rules`, because Codex
    # legitimately persists approvals and preferences into those files.
    settings = { };
    rules = { };
  };
}
