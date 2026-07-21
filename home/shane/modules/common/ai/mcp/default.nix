{
  pkgs,
  ...
}:
let
  rbwRuntimeEnv = ''
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      runtime_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      if [ -d "$runtime_dir" ]; then
        export XDG_RUNTIME_DIR="$runtime_dir"
      fi
    fi
  '';

  aikidoWrapper = pkgs.writeShellApplication {
    name = "aikido-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.aikido-mcp
    ];
    text = ''
      ${rbwRuntimeEnv}
      AIKIDO_API_KEY="$(rbw get aikido-token 2>/dev/null)"
      AIKIDO_MCP_ALL_TOOLS="''${AIKIDO_MCP_ALL_TOOLS:-true}"
      export AIKIDO_API_KEY AIKIDO_MCP_ALL_TOOLS
      exec aikido-mcp
    '';
  };

  context7Wrapper = pkgs.writeShellApplication {
    name = "context7-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      pkgs.context7-mcp
    ];
    text = ''
      ${rbwRuntimeEnv}
      CONTEXT7_API_KEY="$(rbw get context_7_autograb 2>/dev/null)"
      export CONTEXT7_API_KEY
      exec context7-mcp --transport stdio
    '';
  };

in
{
  programs.mcp = {
    enable = true;

    servers = {
      aikido = {
        command = "${aikidoWrapper}/bin/aikido-mcp-wrapper";
        args = [ ];
        env = {
          AIKIDO_MCP_ALL_TOOLS = "true";
        };
      };

      context7 = {
        command = "${context7Wrapper}/bin/context7-mcp-wrapper";
        args = [ ];
      };

      # PostHog exposes a very large MCP surface by default. Keep the shared
      # always-on entry scoped, while allowing feature flag and scheduled-change
      # admin so agents can handle routine product ops.
      posthog = {
        url = "https://mcp.posthog.com/mcp?tools=projects-get,switch-project,project-get,docs-search,read-data-schema,read-data-warehouse-schema,query-run,insight-query,query-error-tracking-issues-list,query-error-tracking-issue,query-error-tracking-issue-events,feature-flag-get-all,feature-flag-get-definition,create-feature-flag,update-feature-flag,delete-feature-flag,feature-flags-activity-retrieve,feature-flags-bulk-update-tags-create,feature-flags-dependent-flags-retrieve,feature-flags-evaluation-reasons-retrieve,feature-flags-status-retrieve,feature-flags-test-evaluation-create,feature-flags-user-blast-radius-create,scheduled-changes-create,scheduled-changes-delete,scheduled-changes-get,scheduled-changes-list,scheduled-changes-update,experiment-list,experiment-get";
      };

      mcphub = {
        url = "https://mcphub.tail1d49f8.ts.net/mcp/$smart";
        env_http_headers = {
          Authorization = "MCPHUB_AUTHORIZATION";
        };
        oauth_resource = "https://mcphub.tail1d49f8.ts.net";
      };
    };
  };
}
