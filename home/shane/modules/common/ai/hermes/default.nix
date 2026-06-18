{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  aiSkills = inputs.ai-skills;
  yamlFormat = pkgs.formats.yaml { };

  profileName = "vex";
  profilePath = ".hermes/profiles/${profileName}";

  soul = builtins.concatStringsSep "\n\n" [
    (builtins.readFile "${aiSkills}/vex/adapters/hermes.md")
    (builtins.readFile "${aiSkills}/vex/rules/shane-profile.md")
    (builtins.readFile "${aiSkills}/vex/rules/exec-function.md")
    (builtins.readFile "${aiSkills}/vex/rules/protocols.md")
    (builtins.readFile "${aiSkills}/vex/rules/brain.md")
  ];

  hermesVexConfig = {
    _config_version = 29;

    model = {
      provider = "openai-codex";
      default = "gpt-5.5";
      base_url = "https://chatgpt.com/backend-api/codex";
    };

    display = {
      busy_ack_enabled = false;
      busy_input_mode = "queue";
      tool_progress = false;
      long_running_notifications = false;
      background_process_notifications = false;
      interim_assistant_messages = false;
    };

    compression.codex_gpt55_autoraise = false;

    agent.gateway_timeout = 3600;

    toolsets = [
      "hermes-cli"
      "messaging"
    ];

    gateway.platforms.bluebubbles.gateway_restart_notification = false;

    onboarding.seen.profile_build_offered = true;

    approvals.destructive_slash_confirm = false;
  };

  mutableProfileDirs = [
    "cron"
    "logs"
    "memories"
    "sessions"
    "skills"
  ];

  mutableProfileKeeps = lib.listToAttrs (
    map (dir: lib.nameValuePair "${profilePath}/${dir}/.keep" { text = ""; }) mutableProfileDirs
  );
in
{
  home.file = {
    "${profilePath}/SOUL.md".text = soul;
    "${profilePath}/config.yaml".source =
      yamlFormat.generate "hermes-${profileName}-config.yaml" hermesVexConfig;

    "${profilePath}/.env.example".text = ''
      # Mutable runtime secrets for the Hermes ${profileName} profile.
      # Copy values into ${profilePath}/.env on the target Mac; do not put real secrets in Nix.

      BLUEBUBBLES_SERVER_URL=
      BLUEBUBBLES_PASSWORD=
      BLUEBUBBLES_ALLOWED_USERS=
      BLUEBUBBLES_REQUIRE_MENTION=true
      BLUEBUBBLES_HOME_CHANNEL=
      BLUEBUBBLES_HOME_CHANNEL_NAME=
      BLUEBUBBLES_WEBHOOK_HOST=127.0.0.1
      BLUEBUBBLES_WEBHOOK_PORT=8646
      BLUEBUBBLES_WEBHOOK_PATH=/bluebubbles-webhook

      TAVILY_API_KEY=
      OPENAI_API_KEY=
      ANTHROPIC_API_KEY=
      GITHUB_TOKEN=
    '';

    "${profilePath}/README.md".text = ''
      # Hermes ${profileName} profile

      This profile is managed from `home/shane/modules/common/ai/hermes/default.nix`.

      Nix-owned files:

      - `config.yaml`: baseline Hermes profile settings.
      - `SOUL.md`: Vex prompt material sourced from the shared AI skills flake.
      - `.env.example`: names the mutable runtime variables without storing secrets.

      Mutable runtime files:

      - `.env`: BlueBubbles connection details and API keys.
      - `auth.json`: Hermes-managed OAuth/provider credentials.
      - `channel_directory.json`, `gateway_state.json`, `state.db`, `cron/`, `logs/`, `memories/`, `sessions/`, `skills/`.

      If OpenAI Codex auth reports `missing access_token`, reauthenticate this profile on the target Mac:

      ```sh
      HERMES_HOME=~/.hermes/profiles/vex hermes auth add openai-codex
      HERMES_HOME=~/.hermes/profiles/vex hermes auth status openai-codex
      ```

      Restart the gateway after changing `.env`, `config.yaml`, or provider auth.
    '';
  }
  // mutableProfileKeeps;
}
