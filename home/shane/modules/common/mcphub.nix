{
  pkgs,
  lib,
  config,
  ...
}:
let
  mcphubDir = "${config.home.homeDirectory}/mcphub";

  # docker-compose.yml — MCPHub + PostgreSQL + Neo4j + Graphiti
  dockerComposeYml = builtins.toJSON {
    services = {
      postgres = {
        image = "pgvector/pgvector:pg17";
        environment = {
          POSTGRES_DB = "mcphub";
          POSTGRES_USER = "mcphub";
          POSTGRES_PASSWORD = "\${POSTGRES_PASSWORD}";
        };
        volumes = [
          "pgdata:/var/lib/postgresql/data"
          "./init-pgvector.sql:/docker-entrypoint-initdb.d/init-pgvector.sql:ro"
        ];
        healthcheck = {
          test = [ "CMD-SHELL" "pg_isready -U mcphub" ];
          interval = "5s";
          timeout = "5s";
          retries = 5;
        };
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };

      neo4j = {
        image = "neo4j:5.26.0";
        environment = {
          NEO4J_AUTH = "neo4j/\${NEO4J_PASSWORD}";
          NEO4J_server_memory_heap_initial__size = "256m";
          NEO4J_server_memory_heap_max__size = "512m";
          NEO4J_server_memory_pagecache_size = "256m";
        };
        volumes = [
          "neo4j_data:/data"
          "neo4j_logs:/logs"
        ];
        healthcheck = {
          test = [ "CMD" "wget" "-O" "/dev/null" "http://localhost:7474" ];
          interval = "10s";
          timeout = "5s";
          retries = 5;
          start_period = "30s";
        };
        ports = [ "7474:7474" "7687:7687" ];
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };

      graphiti-mcp = {
        image = "zepai/knowledge-graph-mcp:standalone";
        depends_on = {
          neo4j = { condition = "service_healthy"; };
        };
        environment = {
          NEO4J_URI = "bolt://neo4j:7687";
          NEO4J_USER = "neo4j";
          NEO4J_PASSWORD = "\${NEO4J_PASSWORD}";
          NEO4J_DATABASE = "neo4j";
          OPENAI_API_KEY = "\${OPENAI_API_KEY}";
          GRAPHITI_GROUP_ID = "vex";
          SEMAPHORE_LIMIT = "10";
          CONFIG_PATH = "/app/mcp/config/config.yaml";
          GRAPHITI_TELEMETRY_ENABLED = "false";
        };
        volumes = [
          "./graphiti-config.yaml:/app/mcp/config/config.yaml:ro"
        ];
        ports = [ "8000:8000" ];
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };

      mcphub = {
        image = "samanhappy/mcphub:latest";
        ports = [ "3000:3000" ];
        env_file = [ ".env" ];
        extra_hosts = [ "host.docker.internal:host-gateway" ];
        depends_on = {
          postgres = {
            condition = "service_healthy";
          };
          graphiti-mcp = {
            condition = "service_started";
          };
        };
        volumes = [
          "./mcp_settings.json:/app/mcp_settings.json"
          "mcphub-data:/app/data"
          "\${HOME}/mcp-memory:/data/memory"
          "\${HOME}/Prime:/data/obsidian:ro"
          "/tmp:/tmp"
          "\${HOME}/.google_workspace_mcp/credentials:/root/.google_workspace_mcp/credentials"
        ];
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };
    };

    volumes = {
      pgdata = {};
      mcphub-data = {};
      neo4j_data = {};
      neo4j_logs = {};
    };

    networks = {
      mcphub = {
        driver = "bridge";
      };
    };
  };

  # mcp_settings.json template — server definitions only, all other config via dashboard
  mcpSettingsTemplate = builtins.toJSON {
    mcpServers = {
      memory = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-memory" ];
        env = {
          MEMORY_FILE_PATH = "/data/memory/memory.jsonl";
        };
      };
      graphiti = {
        command = "npx";
        args = [ "-y" "mcp-remote" "http://graphiti-mcp:8000/mcp" "--allow-http" ];
      };
      todoist = {
        command = "sh";
        args = [ "-c" "TODOIST_API_TOKEN=$TODOIST_API_TOKEN exec npx -y @greirson/mcp-todoist" ];
      };
      github = {
        command = "sh";
        args = [ "-c" "GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN exec npx -y @modelcontextprotocol/server-github" ];
      };
      context7 = {
        command = "sh";
        args = [ "-c" "exec npx -y @upstash/context7-mcp@latest" ];
        env = {
          DEFAULT_MINIMUM_TOKENS = "10000";
        };
      };
      google-workspace = {
        command = "sh";
        args = [ "-c" "GOOGLE_OAUTH_CLIENT_ID=$GOOGLE_OAUTH_CLIENT_ID GOOGLE_OAUTH_CLIENT_SECRET=$GOOGLE_OAUTH_CLIENT_SECRET exec uvx workspace-mcp" ];
      };
      obsidian = {
        command = "npx";
        args = [ "-y" "@mauricio.wolff/mcp-obsidian@latest" "/data/obsidian" ];
      };
      neovim = {
        command = "npx";
        args = [ "-y" "mcp-neovim-server" ];
        env = {
          NVIM_SOCKET_PATH = "/tmp/nvim";
        };
      };
      shadcn = {
        command = "npx";
        args = [ "shadcn@latest" "mcp" ];
      };
      tailscale = {
        command = "sh";
        args = [ "-c" "TAILSCALE_API_KEY=$TAILSCALE_API_KEY TAILSCALE_TAILNET=$TAILSCALE_TAILNET exec npx -y @hexsleeves/tailscale-mcp-server" ];
      };
    };
  };

in
{
  # docker-compose.yml
  home.file."mcphub/docker-compose.yml".text = dockerComposeYml;

  # pgvector init script
  home.file."mcphub/init-pgvector.sql".text = ''
    CREATE EXTENSION IF NOT EXISTS vector;
  '';

  # Graphiti config — Neo4j database + OpenAI for LLM extraction + embeddings
  home.file."mcphub/graphiti-config.yaml".text = ''
    database:
      provider: "neo4j"
      providers:
        neo4j:
          uri: ''${NEO4J_URI:bolt://neo4j:7687}
          username: ''${NEO4J_USER:neo4j}
          password: ''${NEO4J_PASSWORD:demodemo}
          database: ''${NEO4J_DATABASE:neo4j}
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

  # Activation script: generate .env and patch mcp_settings.json with secrets
  home.activation.mcphubConfig = lib.hm.dag.entryAfter [ "writeBoundary" "agenixInstall" ] ''
    MCPHUB_DIR="${mcphubDir}"
    $DRY_RUN_CMD mkdir -p "$MCPHUB_DIR"

    # Ensure mcp-memory directory exists
    $DRY_RUN_CMD mkdir -p "$HOME/mcp-memory"

    # Generate .env from agenix secrets
    $DRY_RUN_CMD install -m 600 /dev/null "$MCPHUB_DIR/.env"
    $DRY_RUN_CMD sh -c 'cat > "'"$MCPHUB_DIR"'/.env" << ENVEOF
TODOIST_API_TOKEN=$(cat ${config.age.secrets.todoist.path})
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github.path})
CONTEXT7_API_KEY=$(cat ${config.age.secrets.context7.path})
POSTHOG_API_KEY=$(cat ${config.age.secrets.posthog.path})
OPENAI_API_KEY=$(cat ${config.age.secrets.openai.path})
MCPHUB_BEARER_TOKEN=$(cat ${config.age.secrets.mcphub-bearer.path})
GOOGLE_OAUTH_CLIENT_ID=$(cat ${config.age.secrets.google-oauth-client-id.path})
GOOGLE_OAUTH_CLIENT_SECRET=$(cat ${config.age.secrets.google-oauth-client-secret.path})
TAILSCALE_API_KEY=$(cat ${config.age.secrets.tailscale-api.path})
TAILSCALE_TAILNET=$(cat ${config.age.secrets.tailscale-tailnet.path})
POSTGRES_PASSWORD=mcphub
NEO4J_PASSWORD=graphiti-poc
ENVEOF'

    # Always sync mcpServers from nix, preserve everything else (bearerKeys, users, systemConfig)
    TEMPLATE='${builtins.toFile "mcp_settings_template.json" mcpSettingsTemplate}'
    if [ -f "$MCPHUB_DIR/mcp_settings.json" ]; then
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq -s '.[0] * { mcpServers: .[1].mcpServers }' \
        "$MCPHUB_DIR/mcp_settings.json" "$TEMPLATE" \
        > "$MCPHUB_DIR/mcp_settings.json.tmp" \
        && mv "$MCPHUB_DIR/mcp_settings.json.tmp" "$MCPHUB_DIR/mcp_settings.json"
    else
      $DRY_RUN_CMD cp "$TEMPLATE" "$MCPHUB_DIR/mcp_settings.json"
    fi

    $DRY_RUN_CMD chmod 600 "$MCPHUB_DIR/.env" "$MCPHUB_DIR/mcp_settings.json"
  '';
}
