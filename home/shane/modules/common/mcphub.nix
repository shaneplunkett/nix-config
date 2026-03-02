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
        build = {
          context = ".";
          dockerfile = "Dockerfile";
        };
        ports = [ "3000:3000" ];
        env_file = [ ".env" ];
        extra_hosts = [ "host.docker.internal:host-gateway" ];
        cap_add = [ "NET_ADMIN" "NET_RAW" ];
        devices = [ "/dev/net/tun:/dev/net/tun" ];
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
          "tailscale-state:/var/lib/tailscale"
        ];
        networks = [ "mcphub" ];
        restart = "unless-stopped";
      };
    };

    volumes = {
      pgdata = {};
      mcphub-data = {};
      tailscale-state = {};
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

  # Activation script: generate .env and patch mcp_settings.json with secrets
  home.activation.mcphubConfig = lib.hm.dag.entryAfter [ "writeBoundary" "agenixInstall" ] ''
    MCPHUB_DIR="${mcphubDir}"
    $DRY_RUN_CMD mkdir -p "$MCPHUB_DIR"

    # Dockerfile — cp from nix store so it's a real file (Docker can't follow symlinks outside build context)
    $DRY_RUN_CMD install -m 644 '${builtins.toFile "mcphub-Dockerfile" ''
      FROM samanhappy/mcphub:latest
      RUN apt-get update \
        && apt-get install -y curl iptables \
        && curl -fsSL https://tailscale.com/install.sh | sh \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
      COPY entrypoint-wrapper.sh /usr/local/bin/entrypoint-wrapper.sh
      ENTRYPOINT ["/usr/local/bin/entrypoint-wrapper.sh"]
      CMD ["pnpm", "start"]
    ''}' "$MCPHUB_DIR/Dockerfile"

    # Entrypoint wrapper — starts tailscaled then hands off to MCPHub
    $DRY_RUN_CMD install -m 755 '${builtins.toFile "entrypoint-wrapper.sh" ''
      #!/bin/sh
      tailscaled --state=/var/lib/tailscale/tailscaled.state &
      sleep 2
      if [ -n "$TAILSCALE_AUTH_KEY" ]; then
        tailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname=mcphub --accept-routes
      fi
      exec /usr/local/bin/entrypoint.sh "$@"
    ''}' "$MCPHUB_DIR/entrypoint-wrapper.sh"

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
TAILSCALE_AUTH_KEY=$(cat ${config.age.secrets.tailscale-authkey.path})
POSTGRES_PASSWORD=mcphub
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
