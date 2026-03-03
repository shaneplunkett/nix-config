{ pkgs, config, lib, ... }:
let
  mcphubRepo = "https://github.com/samanhappy/mcphub.git";

  # mcp_settings.json — server definitions for MCPHub on the VM
  # Excluded: neovim (desktop-only), obsidian (desktop-only)
  mcpSettingsTemplate = builtins.toJSON {
    mcpServers = {
      memory = {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-memory" ];
        env = {
          MEMORY_FILE_PATH = "/var/lib/mcphub/memory/memory.jsonl";
        };
      };
      graphiti = {
        command = "npx";
        args = [ "-y" "mcp-remote" "http://127.0.0.1:8000/mcp" "--allow-http" ];
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
  users.users.mcphub = {
    isSystemUser = true;
    group = "mcphub";
    home = "/var/lib/mcphub";
    createHome = true;
  };
  users.groups.mcphub = { };

  systemd.services.mcphub = {
    description = "MCPHub Server";
    after = [ "postgresql.service" "graphiti-mcp.service" "network.target" ];
    wants = [ "postgresql.service" "graphiti-mcp.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.nodejs
      pkgs.pnpm
      pkgs.uv
      pkgs.python312
      pkgs.git
      pkgs.bash
      pkgs.coreutils
    ];

    serviceConfig = {
      User = "mcphub";
      Group = "mcphub";
      WorkingDirectory = "/var/lib/mcphub";
      StateDirectory = "mcphub";
      RuntimeDirectory = "mcphub";

      ExecStartPre = let
        setupScript = pkgs.writeShellScript "mcphub-setup" ''
          set -euo pipefail
          REPO_DIR="/var/lib/mcphub/mcphub-repo"
          MEMORY_DIR="/var/lib/mcphub/memory"

          # Ensure memory directory exists
          mkdir -p "$MEMORY_DIR"

          # Clone or pull MCPHub repo
          if [ ! -d "$REPO_DIR/.git" ]; then
            ${pkgs.git}/bin/git clone ${mcphubRepo} "$REPO_DIR"
          else
            cd "$REPO_DIR"
            ${pkgs.git}/bin/git pull --ff-only || true
          fi

          # Install dependencies and build
          cd "$REPO_DIR"
          export HOME="/var/lib/mcphub"
          export npm_config_cache="/var/lib/mcphub/.npm"
          export NODE_OPTIONS="--max-old-space-size=512"
          unset NODE_ENV
          ${pkgs.pnpm}/bin/pnpm install
          # Only build if dist/ doesn't exist (first deploy or after clearing)
          # pnpm build has systemd sandbox incompatibilities — run manually if needed:
          #   sudo -u mcphub env HOME=/var/lib/mcphub pnpm -C /var/lib/mcphub/mcphub-repo build
          if [ ! -f "$REPO_DIR/dist/index.js" ]; then
            ${pkgs.pnpm}/bin/pnpm build
          fi

          # Compose env file from agenix secrets
          cat > /var/lib/mcphub/env <<EOF
TODOIST_API_TOKEN=$(cat ${config.age.secrets.todoist.path})
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat ${config.age.secrets.github.path})
CONTEXT7_API_KEY=$(cat ${config.age.secrets.context7.path})
OPENAI_API_KEY=$(cat ${config.age.secrets.openai.path})
MCPHUB_BEARER_TOKEN=$(cat ${config.age.secrets.mcphub-bearer.path})
GOOGLE_OAUTH_CLIENT_ID=$(cat ${config.age.secrets.google-oauth-client-id.path})
GOOGLE_OAUTH_CLIENT_SECRET=$(cat ${config.age.secrets.google-oauth-client-secret.path})
TAILSCALE_API_KEY=$(cat ${config.age.secrets.tailscale-api.path})
TAILSCALE_TAILNET=$(cat ${config.age.secrets.tailscale-tailnet.path})
DATABASE_URL=postgresql://mcphub@localhost/mcphub
EOF
          chown mcphub:mcphub /var/lib/mcphub/env
          chmod 600 /var/lib/mcphub/env

          # Deploy mcp_settings.json — merge mcpServers from template, preserve dashboard config
          TEMPLATE='${builtins.toFile "mcp_settings_template.json" mcpSettingsTemplate}'
          SETTINGS="/var/lib/mcphub/mcphub-repo/mcp_settings.json"
          if [ -f "$SETTINGS" ]; then
            ${pkgs.jq}/bin/jq -s '.[0] + { mcpServers: .[1].mcpServers }' \
              "$SETTINGS" "$TEMPLATE" > "$SETTINGS.tmp" \
              && mv "$SETTINGS.tmp" "$SETTINGS"
          else
            cp "$TEMPLATE" "$SETTINGS"
          fi
          chown mcphub:mcphub "$SETTINGS"

          # Set up Google Workspace OAuth credentials directory
          mkdir -p "/var/lib/mcphub/.google_workspace_mcp/credentials"

          # Fix ownership — ExecStartPre runs as root, service runs as mcphub
          chown -R mcphub:mcphub /var/lib/mcphub
        '';
      in "+${setupScript}";

      ExecStart = "${pkgs.nodejs}/bin/node /var/lib/mcphub/mcphub-repo/dist/index.js";
      EnvironmentFile = "-/var/lib/mcphub/env";

      Environment = [
        "HOME=/var/lib/mcphub"
        "npm_config_cache=/var/lib/mcphub/.npm"
        "NODE_ENV=production"
      ];

      # Hardening
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/mcphub" "/run/mcphub" "/tmp" ];
      ProtectHome = true;

      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
