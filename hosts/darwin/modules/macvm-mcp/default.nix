{ pkgs, lib, ... }:
let
  mkMcpDaemon =
    {
      name,
      port,
      repoUrl,
      runtime ? "node",
      stdioCmd,
      extraEnv ? { },
    }:
    let
      stateDir = "/var/lib/mcp-servers/${name}";

      setupScript = pkgs.writeShellScript "${name}-setup" ''
        set -euo pipefail
        REPO_DIR="${stateDir}/repo"

        mkdir -p "${stateDir}"

        # Clone or update
        if [ ! -d "$REPO_DIR/.git" ]; then
          ${pkgs.git}/bin/git clone ${repoUrl} "$REPO_DIR"
        else
          cd "$REPO_DIR"
          ${pkgs.git}/bin/git pull --ff-only || true
        fi

        cd "$REPO_DIR"

        ${if runtime == "python" then ''
          ${pkgs.uv}/bin/uv sync --python ${pkgs.python312}/bin/python3
        '' else ''
          ${pkgs.nodejs}/bin/npm install --production 2>/dev/null || ${pkgs.nodejs}/bin/npm install
          if [ -f package.json ] && grep -q '"build"' package.json; then
            ${pkgs.nodejs}/bin/npm run build || true
          fi
        ''}

        chown -R shane:staff "${stateDir}"
      '';

      startScript = pkgs.writeShellScript "${name}-start" ''
        set -euo pipefail
        ${setupScript}
        cd ${stateDir}/repo
        exec ${pkgs.nodejs}/bin/npx -y supergateway \
          --stdio "${stdioCmd stateDir}" \
          --port ${toString port} \
          --baseUrl /mcp \
          --outputTransport streamableHttp
      '';
    in
    {
      launchd.daemons."mcp-${name}" = {
        serviceConfig = {
          Label = "com.mcp.${name}";
          ProgramArguments = [ "${startScript}" ];
          RunAtLoad = true;
          KeepAlive = true;
          UserName = "shane";
          WorkingDirectory = "/tmp";
          StandardOutPath = "/var/log/mcp/${name}.log";
          StandardErrorPath = "/var/log/mcp/${name}.err";
          EnvironmentVariables = {
            HOME = "/Users/shane";
            PATH = "${lib.makeBinPath [
              pkgs.nodejs
              pkgs.python312
              pkgs.uv
              pkgs.git
            ]}:/usr/bin:/bin:/usr/sbin:/sbin";
          } // extraEnv;
        };
      };
    };

  # Phase 1 servers
  servers = [
    (mkMcpDaemon {
      name = "apple-mail";
      port = 8010;
      repoUrl = "https://github.com/imdinu/apple-mail-mcp.git";
      runtime = "python";
      stdioCmd = dir: "${pkgs.uv}/bin/uv run --directory ${dir}/repo python -m apple_mail_mcp";
    })
    (mkMcpDaemon {
      name = "mac-messages";
      port = 8011;
      repoUrl = "https://github.com/carterlasalle/mac_messages_mcp.git";
      runtime = "python";
      stdioCmd = dir: "${pkgs.uv}/bin/uv run --directory ${dir}/repo python -m mac_messages_mcp";
    })
    (mkMcpDaemon {
      name = "applescript";
      port = 8012;
      repoUrl = "https://github.com/joshrutkowski/applescript-mcp.git";
      runtime = "node";
      stdioCmd = dir: "${pkgs.nodejs}/bin/node ${dir}/repo/dist/index.js";
    })
    (mkMcpDaemon {
      name = "apple-shortcuts";
      port = 8013;
      repoUrl = "https://github.com/recursechat/mcp-server-apple-shortcuts.git";
      runtime = "node";
      stdioCmd = dir: "${pkgs.nodejs}/bin/node ${dir}/repo/dist/index.js";
    })
    # Phase 2 — uncomment when ready:
    # (mkMcpDaemon {
    #   name = "macos-automator";
    #   port = 8014;
    #   repoUrl = "https://github.com/steipete/macos-automator-mcp.git";
    #   runtime = "node";
    #   stdioCmd = dir: "${pkgs.nodejs}/bin/node ${dir}/repo/dist/index.js";
    # })
    # (mkMcpDaemon {
    #   name = "apple-music";
    #   port = 8015;
    #   repoUrl = "https://github.com/kennethreitz/mcp-applemusic.git";
    #   runtime = "python";
    #   stdioCmd = dir: "${pkgs.uv}/bin/uv run --directory ${dir}/repo python -m mcp_applemusic";
    # })
    # (mkMcpDaemon {
    #   name = "macos-notifications";
    #   port = 8016;
    #   repoUrl = "https://github.com/devizor/macos-notification-mcp.git";
    #   runtime = "python";
    #   stdioCmd = dir: "${pkgs.uv}/bin/uv run --directory ${dir}/repo python -m macos_notification_mcp";
    # })
  ];
in
{
  # Merge all server launchd daemon definitions
  launchd.daemons = lib.mkMerge (map (s: s.launchd.daemons) servers);

  # Shared packages needed on the VM
  environment.systemPackages = with pkgs; [
    nodejs
    python312
    uv
    git
  ];

  # Ensure state and log directories exist
  system.activationScripts.mcpDirs.text = ''
    mkdir -p /var/lib/mcp-servers /var/log/mcp
    chown -R shane:staff /var/lib/mcp-servers /var/log/mcp
  '';
}
