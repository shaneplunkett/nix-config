{
  pkgs,
  lib,
  config,
  ...
}:
let
  mcphubDir = "${config.home.homeDirectory}/mcphub";

  # docker-compose.yml — MCPHub + PostgreSQL with pgvector
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

      mcphub = {
        image = "samanhappy/mcphub:latest";
        ports = [ "3000:3000" ];
        env_file = [ ".env" ];
        extra_hosts = [ "host.docker.internal:host-gateway" ];
        depends_on = {
          postgres = {
            condition = "service_healthy";
          };
        };
        volumes = [
          "./mcp_settings.json:/app/mcp_settings.json"
          "mcphub-data:/app/data"
          "\${HOME}/mcp-memory:/data/memory"
          "\${HOME}/Prime:/data/obsidian:ro"
          "/tmp:/tmp"
        ];
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };
    };

    volumes = {
      pgdata = {};
      mcphub-data = {};
    };

    networks = {
      mcphub = {
        driver = "bridge";
      };
    };
  };

  # mcp_settings.json template — secrets patched in at activation time
  mcpSettingsTemplate = builtins.toJSON {
    mcpServers = {
      memory = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-memory" ];
        env = {
          MEMORY_FILE_PATH = "/data/memory/memory.jsonl";
        };
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
      posthog = {
        command = "sh";
        args = [ "-c" "exec npx -y mcp-remote@latest https://mcp.posthog.com/mcp --header \"x-posthog-api-key:$POSTHOG_API_KEY\"" ];
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
    };
    smartRouting = {
      enabled = true;
      dbUrl = "postgresql://mcphub:mcphub@postgres:5432/mcphub";
      embeddingProvider = "openai";
      openaiApiKey = "__OPENAI_API_KEY__";
      openaiApiEmbeddingModel = "text-embedding-3-small";
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
POSTGRES_PASSWORD=mcphub
ENVEOF'

    # Patch mcp_settings.json with secrets from agenix
    OPENAI_KEY="$(cat ${config.age.secrets.openai.path})"
    BEARER_TOKEN="$(cat ${config.age.secrets.mcphub-bearer.path})"

    $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
      --arg openai "$OPENAI_KEY" \
      --arg bearer "$BEARER_TOKEN" \
      '.smartRouting.openaiApiKey = $openai | .mcpServers.bearer_token = $bearer' \
      ${builtins.toFile "mcp_settings_template.json" mcpSettingsTemplate} \
      > "$MCPHUB_DIR/mcp_settings.json"

    $DRY_RUN_CMD chmod 600 "$MCPHUB_DIR/.env" "$MCPHUB_DIR/mcp_settings.json"
  '';
}
