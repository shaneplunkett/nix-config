{
  inputs,
  pkgs,
  ...
}:

let
  hermesAgent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.messaging;

  hermesVexGateway = pkgs.writeShellApplication {
    name = "hermes-vex-gateway";
    runtimeInputs = [
      hermesAgent
      pkgs.python3
    ];
    text = ''
      set -euo pipefail

      profile="''${1:-vex}"
      env_file="$HOME/.hermes/profiles/$profile/.env"
      mkdir -p "$HOME/.hermes/profiles/$profile/logs"

      clean_webhooks() {
        if [[ ! -f "$env_file" ]]; then
          return 0
        fi

        python3 - "$env_file" <<'PY'
      import json
      import sys
      import urllib.error
      import urllib.parse
      import urllib.request

      env_file = sys.argv[1]
      env = {}
      with open(env_file, "r", encoding="utf-8") as handle:
          for raw_line in handle:
              line = raw_line.strip()
              if not line or line.startswith("#") or "=" not in line:
                  continue
              key, value = line.split("=", 1)
              env[key] = value

      server = env.get("BLUEBUBBLES_SERVER_URL", "").rstrip("/")
      password = env.get("BLUEBUBBLES_PASSWORD", "")
      host = env.get("BLUEBUBBLES_WEBHOOK_HOST", "127.0.0.1")
      port = int(env.get("BLUEBUBBLES_WEBHOOK_PORT", "8646"))
      path = env.get("BLUEBUBBLES_WEBHOOK_PATH", "/bluebubbles-webhook")
      if not path.startswith("/"):
          path = "/" + path

      if not server or not password:
          sys.exit(0)

      quoted_password = urllib.parse.quote(password, safe="")
      wanted_url = f"http://{host}:{port}{path}?password={quoted_password}"
      wanted_events = ["new-message"]

      def api_url(api_path):
          query = urllib.parse.urlencode({"password": password})
          sep = "&" if "?" in api_path else "?"
          return f"{server}{api_path}{sep}{query}"

      def request(method, api_path, payload=None):
          body = None
          headers = {}
          if payload is not None:
              body = json.dumps(payload).encode("utf-8")
              headers["Content-Type"] = "application/json"
          req = urllib.request.Request(api_url(api_path), data=body, method=method, headers=headers)
          with urllib.request.urlopen(req, timeout=5) as response:
              data = response.read()
          if not data:
              return {}
          return json.loads(data.decode("utf-8"))

      try:
          current = request("GET", "/api/v1/webhook").get("data", [])
      except (OSError, urllib.error.URLError, json.JSONDecodeError):
          sys.exit(0)

      kept_wanted = False
      for webhook in current:
          webhook_id = webhook.get("id")
          url = webhook.get("url", "")
          events = webhook.get("events", [])
          parsed = urllib.parse.urlsplit(url)
          is_hermes_webhook = parsed.port == port and parsed.path == path
          is_exact_wanted = url == wanted_url and events == wanted_events

          should_delete = False
          if is_exact_wanted:
              if kept_wanted:
                  should_delete = True
              else:
                  kept_wanted = True
          elif is_hermes_webhook:
              should_delete = True

          if should_delete and webhook_id is not None:
              try:
                  request("DELETE", f"/api/v1/webhook/{webhook_id}")
              except (OSError, urllib.error.URLError, json.JSONDecodeError):
                  pass

      if not kept_wanted:
          try:
              request("POST", "/api/v1/webhook", {"url": wanted_url, "events": wanted_events})
          except (OSError, urllib.error.URLError, json.JSONDecodeError):
              pass
      PY
      }

      monitor_webhooks() {
        for ((i = 0; i < 12; i++)); do
          sleep 5
          clean_webhooks || true
        done
        while sleep 60; do
          clean_webhooks || true
        done
      }

      clean_webhooks || true
      monitor_webhooks &
      monitor_pid="$!"

      hermes -p "$profile" gateway run --replace --accept-hooks &
      gateway_pid="$!"

      cleanup() {
        kill "$monitor_pid" 2>/dev/null || true
        kill "$gateway_pid" 2>/dev/null || true
      }
      trap cleanup EXIT INT TERM

      wait "$gateway_pid"
    '';
  };
in

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  users.users.vex.home = "/Users/vex";

  home-manager.users.vex = import ../../home/vex/homemac.nix;

  environment.systemPackages = [
    hermesVexGateway
  ];

  launchd.user.agents.hermes-vex-gateway.serviceConfig = {
    ProgramArguments = [
      "${hermesVexGateway}/bin/hermes-vex-gateway"
      "vex"
    ];
    RunAtLoad = true;
    KeepAlive = true;
    WorkingDirectory = "/Users/shane";
    EnvironmentVariables = {
      HOME = "/Users/shane";
    };
    StandardOutPath = "/Users/shane/.hermes/profiles/vex/logs/launchd.out.log";
    StandardErrorPath = "/Users/shane/.hermes/profiles/vex/logs/launchd.err.log";
  };

  power.sleep = {
    computer = "never";
    display = "never";
    harddisk = "never";
  };

  system = {
    activationScripts = {
      hermesVexGatewayLogs.text = ''
        mkdir -p /Users/shane/.hermes/profiles/vex/logs
        chown shane:staff /Users/shane/.hermes /Users/shane/.hermes/profiles /Users/shane/.hermes/profiles/vex /Users/shane/.hermes/profiles/vex/logs 2>/dev/null || true
      '';
    };

    stateVersion = 6;
  };
}
