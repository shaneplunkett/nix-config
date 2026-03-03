{ pkgs, config, lib, ... }:
let
  graphitiRepo = "https://github.com/getzep/graphiti.git";

  # Graphiti config YAML — Neo4j on localhost, OpenAI via env var
  graphitiConfig = pkgs.writeText "graphiti-config.yaml" ''
    database:
      provider: "neo4j"
      providers:
        neo4j:
          uri: bolt://127.0.0.1:7687
          username: neo4j
          password: graphiti-poc
          database: neo4j
          use_parallel_runtime: false

    llm:
      provider: "openai"
      model: "gpt-4o-mini"
      max_tokens: 4096
      providers:
        openai:
          api_key: ''${OPENAI_API_KEY}
          api_url: https://api.openai.com/v1

    embedder:
      provider: "openai"
      model: "text-embedding-3-small"
      dimensions: 1536
      providers:
        openai:
          api_key: ''${OPENAI_API_KEY}
          api_url: https://api.openai.com/v1
  '';
in
{
  users.users.graphiti = {
    isSystemUser = true;
    group = "graphiti";
    home = "/var/lib/graphiti";
    createHome = true;
  };
  users.groups.graphiti = { };

  systemd.services.graphiti-mcp = {
    description = "Graphiti MCP Server";
    after = [ "neo4j.service" "network.target" ];
    requires = [ "neo4j.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.uv pkgs.python312 pkgs.git ];

    serviceConfig = {
      User = "graphiti";
      Group = "graphiti";
      WorkingDirectory = "/var/lib/graphiti/repo/mcp_server";
      StateDirectory = "graphiti";
      RuntimeDirectory = "graphiti";

      ExecStartPre = let
        setupScript = pkgs.writeShellScript "graphiti-setup" ''
          set -euo pipefail
          REPO_DIR="/var/lib/graphiti/repo"

          # Clone or pull the graphiti repo
          if [ ! -d "$REPO_DIR/.git" ]; then
            ${pkgs.git}/bin/git clone ${graphitiRepo} "$REPO_DIR"
          else
            cd "$REPO_DIR"
            ${pkgs.git}/bin/git pull --ff-only || true
          fi

          # Write env file from agenix secrets
          cat > /run/graphiti/env <<EOF
          OPENAI_API_KEY=$(cat ${config.age.secrets.openai.path})
          NEO4J_URI=bolt://127.0.0.1:7687
          NEO4J_USER=neo4j
          NEO4J_PASSWORD=graphiti-poc
          NEO4J_DATABASE=neo4j
          GRAPHITI_GROUP_ID=vex
          SEMAPHORE_LIMIT=10
          CONFIG_PATH=${graphitiConfig}
          GRAPHITI_TELEMETRY_ENABLED=false
          EOF

          # Install dependencies
          cd "$REPO_DIR/mcp_server"
          ${pkgs.uv}/bin/uv sync
        '';
      in "+${setupScript}";

      ExecStart = "${pkgs.uv}/bin/uv run main.py --database-provider neo4j --transport http --host 0.0.0.0 --port 8000";
      EnvironmentFile = "/run/graphiti/env";

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/graphiti" "/run/graphiti" ];
      ProtectHome = true;

      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
