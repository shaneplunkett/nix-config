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
  vexRoot = "${aiSkills}/vex";
  tomlFormat = pkgs.formats.toml { };

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

  globalSkillNames = [
    "bb-browserbase"
    "compass-autograb"
    "confluence-autograb"
    "confluence-pretty-publisher"
    "github-gh"
    "gmail"
    "google-calendar"
    "google-drive"
    "jira-autograb"
    "langsmith-autograb"
    "memory-save"
    "slack-autograb"
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
  availableGlobalSkillNames = builtins.filter (
    name: builtins.hasAttr name personalSkillsAttrs
  ) globalSkillNames;
  globalSkillsAttrs = lib.genAttrs availableGlobalSkillNames (name: personalSkillsAttrs.${name});

  vexRuleFiles = lib.pipe "${vexRoot}/rules" [
    builtins.readDir
    (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n))
    lib.attrNames
    (map (n: "${vexRoot}/rules/${n}"))
  ];

  vexAgentsMd = lib.concatMapStringsSep "\n\n" builtins.readFile (
    [
      "${vexRoot}/core.md"
      "${vexRoot}/output-style.md"
      "${vexRoot}/adapters/openai-codex.md"
    ]
    ++ vexRuleFiles
  );

  codex-emit-context = mkBashHook {
    name = "codex-emit-context";
    runtimeInputs = [ pkgs.jq ];
    script = ./codex-emit-context.sh;
  };

  codex-nix-lint = mkBashHook {
    name = "codex-nix-lint";
    runtimeInputs = [
      pkgs.jq
      pkgs.statix
      pkgs.deadnix
    ];
    script = ./codex-nix-lint.sh;
  };

  codex-git-commit-guard = pkgs.writeShellApplication {
    name = "codex-git-commit-guard";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
    ];
    text = ''exec ${pkgs.bash}/bin/bash ${../git-commit-guard.sh} codex "$@"'';
  };

  rbwRuntimeEnv = ''
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      runtime_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      if [ -d "$runtime_dir" ]; then
        export XDG_RUNTIME_DIR="$runtime_dir"
      fi
    fi
  '';

  codexBasePackage = pkgs.codex-patched;
  codexPackage = pkgs.writeShellApplication {
    name = "codex";
    runtimeInputs = [
      pkgs.rbw
    ];
    text = ''
      ${rbwRuntimeEnv}
      mcphub_token="$(rbw get mcphub-bearer 2>/dev/null || true)"
      if [ -n "$mcphub_token" ]; then
        export MCPHUB_AUTHORIZATION="Bearer $mcphub_token"
      fi

      exec ${codexBasePackage}/bin/codex "$@"
    '';
  };
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
        # Shared MCP entries may carry Claude/RMCP OAuth metadata. Codex treats
        # these as an instruction to start an OAuth flow during MCP initialise,
        # which breaks non-OAuth HTTP servers such as Shane's MCPHub proxy.
        "oauth"
        "oauth_resource"
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

  codexHooks = {
    SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = "${codex-emit-context}/bin/codex-emit-context SessionStart ${vexRoot}/hooks/session-start.md";
            timeout = 10;
          }
        ];
      }
    ];

    PreToolUse = [
      {
        matcher = "exec_command|functions.exec_command|Bash|shell";
        hooks = [
          {
            type = "command";
            command = "${codex-git-commit-guard}/bin/codex-git-commit-guard";
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

  codexSettings = {
    model = "gpt-5.6";
    model_reasoning_effort = "high";
    project_doc_max_bytes = 65536;

    features = {
      hooks = true;
      memories = false;
    };

    memories = {
      generate_memories = false;
      use_memories = false;
    };

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

    shell_environment_policy."inherit" = "all";

    sandbox_mode = "danger-full-access";
    approval_policy = "never";

    projects."/home/shane/nix-config".trust_level = "trusted";

    agents = {
      max_threads = 4;
      max_depth = 2;
    };

    hooks = codexHooks;
  }
  // lib.optionalAttrs (transformedMcpServers != { }) {
    mcp_servers = transformedMcpServers;
  };

  codexConfigSeed = tomlFormat.generate "codex-config.toml" codexSettings;

  codexConfigMerger = pkgs.writeShellApplication {
    name = "codex-config-merge";
    runtimeInputs = [
      (pkgs.python3.withPackages (pythonPackages: [ pythonPackages.tomli-w ]))
    ];
    text = ''
            exec python3 - "$@" <<'PY'
      import pathlib
      import sys
      import tomllib

      import tomli_w

      REPLACE_SUBTREES = {
          ("hooks",),
          ("mcp_servers",),
          ("memories",),
      }


      def read_toml(path):
          if not path.exists():
              return {}
          with path.open("rb") as fh:
              return tomllib.load(fh)


      def merge(base, managed):
          for key, value in managed.items():
              if isinstance(value, dict) and isinstance(base.get(key), dict):
                  merge(base[key], value)
              else:
                  base[key] = value
          return base


      def delete_path(data, path):
          cursor = data
          for key in path[:-1]:
              child = cursor.get(key)
              if not isinstance(child, dict):
                  return
              cursor = child
          cursor.pop(path[-1], None)


      def leaf_paths(data, prefix=()):
          for key, value in data.items():
              path = prefix + (key,)
              if isinstance(value, dict):
                  yield from leaf_paths(value, path)
              else:
                  yield path


      managed_path = pathlib.Path(sys.argv[1])
      target_path = pathlib.Path(sys.argv[2])

      managed = read_toml(managed_path)
      target = read_toml(target_path)

      for path in REPLACE_SUBTREES:
          delete_path(target, path)
      for path in leaf_paths(managed):
          is_replaced_subtree = any(
              path[: len(subtree)] == subtree for subtree in REPLACE_SUBTREES
          )
          if not is_replaced_subtree:
              delete_path(target, path)

      target_path.parent.mkdir(parents=True, exist_ok=True)
      target_path.write_bytes(tomli_w.dumps(merge(target, managed)).encode())
      PY
    '';
  };

  mutableConfigActivation =
    dir:
    let
      configPath = "${homeDirectory}/${dir}/config.toml";
      managedConfigPath = "${homeDirectory}/${dir}/managed_config.toml";
      rulesPath = "${homeDirectory}/${dir}/rules/default.rules";
    in
    ''
      $DRY_RUN_CMD mkdir -p "${homeDirectory}/${dir}/rules"

      if [ -L "${configPath}" ]; then
        $DRY_RUN_CMD rm "${configPath}"
      fi
      if [ -f "${configPath}" ]; then
        $DRY_RUN_CMD chmod u+w "${configPath}"
      fi
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        ${codexConfigMerger}/bin/codex-config-merge "${codexConfigSeed}" "${configPath}"
      else
        $DRY_RUN_CMD merge managed Codex settings into "${configPath}"
      fi

      for legacyFile in \
        "${managedConfigPath}" \
        "${homeDirectory}/${dir}/vex.config.toml" \
        "${homeDirectory}/${dir}/hooks.json"
      do
        if [ -L "$legacyFile" ]; then
          $DRY_RUN_CMD rm "$legacyFile"
        fi
      done

      if [ -L "${rulesPath}" ]; then
        $DRY_RUN_CMD rm "${rulesPath}"
      fi
      if [ ! -e "${rulesPath}" ]; then
        $DRY_RUN_CMD cp "${./default.rules}" "${rulesPath}"
        $DRY_RUN_CMD chmod u+w "${rulesPath}"
      fi
    '';

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
in
{
  home = {
    file = lib.foldl' lib.recursiveUpdate { } (map filesForVariant codexVariantDirs);

    activation.codexMutableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatMapStringsSep "\n" mutableConfigActivation mutableCodexDirs
    );
  };

  programs = {
    codex = {
      enable = true;
      package = codexPackage;

      context = vexAgentsMd;
      skills = globalSkillsAttrs;
      settings = { };
      rules = { };
    };
  };
}
