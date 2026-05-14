{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  rbw = "${pkgs.rbw}/bin/rbw";

  vexCli = inputs.vex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;

  envLoader = ''
    --run '
    if [ -z "''${CF_ACCESS_CLIENT_ID:-}" ]; then
      CF_ACCESS_CLIENT_ID="$(${rbw} get vex-cli-cf-id 2>/dev/null)"
      [ -n "$CF_ACCESS_CLIENT_ID" ] && export CF_ACCESS_CLIENT_ID
    fi
    if [ -z "''${CF_ACCESS_CLIENT_SECRET:-}" ]; then
      CF_ACCESS_CLIENT_SECRET="$(${rbw} get vex-cli-cf-secret 2>/dev/null)"
      [ -n "$CF_ACCESS_CLIENT_SECRET" ] && export CF_ACCESS_CLIENT_SECRET
    fi
    export VEX_API_ENDPOINT="''${VEX_API_ENDPOINT:-https://vex.shaneplunkett.dev}"
    '
  '';

  vexCliWrapped = pkgs.symlinkJoin {
    name = "vex-cli-wrapped-${vexCli.version or "0.1.0"}";
    paths = [ vexCli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/vex
      makeWrapper ${vexCli}/bin/vex $out/bin/vex ${envLoader}
    '';
    meta = (vexCli.meta or { }) // {
      description = "vex Go CLI wrapped to auto-load CF Access service token from rbw";
    };
  };

  vexEnv = pkgs.writeShellScriptBin "vex-env" ''
    set -e
    CF_ACCESS_CLIENT_ID="$(${rbw} get vex-cli-cf-id 2>/dev/null)"
    CF_ACCESS_CLIENT_SECRET="$(${rbw} get vex-cli-cf-secret 2>/dev/null)"
    if [ -z "$CF_ACCESS_CLIENT_ID" ] || [ -z "$CF_ACCESS_CLIENT_SECRET" ]; then
      echo "vex-env: unable to fetch CF Access creds from rbw (is the agent unlocked?)" >&2
      exit 1
    fi
    export CF_ACCESS_CLIENT_ID CF_ACCESS_CLIENT_SECRET
    export VEX_API_ENDPOINT="''${VEX_API_ENDPOINT:-https://vex.shaneplunkett.dev}"

    if [ $# -eq 0 ]; then
      printf 'CF_ACCESS_CLIENT_ID=%s\nCF_ACCESS_CLIENT_SECRET=%s\nVEX_API_ENDPOINT=%s\n' \
        "$CF_ACCESS_CLIENT_ID" "$CF_ACCESS_CLIENT_SECRET" "$VEX_API_ENDPOINT"
      exit 0
    fi
    exec "$@"
  '';
in
{
  home.packages = [
    vexCliWrapped
    vexEnv
  ];

  # Hourly `vex sync-cc` — Linux uses systemd-user timer, Darwin uses
  # launchd. Both call the same wrapped binary, which exports the CF
  # Access service token + endpoint from rbw before invoking vex.
  # NOTE: rbw agent must be unlocked for the timer to succeed; on a fresh
  # boot the first hourly fire will fail silently until `rbw unlock` runs.

  systemd.user.services = lib.mkIf pkgs.stdenv.isLinux {
    vex-sync-cc = {
      Unit = {
        Description = "Push new Claude Code sessions to vex-brain";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${vexCliWrapped}/bin/vex sync-cc";
        SuccessExitStatus = "0";
      };
    };
  };

  systemd.user.timers = lib.mkIf pkgs.stdenv.isLinux {
    vex-sync-cc = {
      Unit = {
        Description = "Hourly vex sync-cc";
      };
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "1h";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  launchd.agents = lib.mkIf pkgs.stdenv.isDarwin {
    vex-sync-cc = {
      enable = true;
      config = {
        Label = "dev.shaneplunkett.vex-sync-cc";
        ProgramArguments = [
          "${vexCliWrapped}/bin/vex"
          "sync-cc"
        ];
        StartInterval = 3600;
        RunAtLoad = false;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/vex-sync-cc.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/vex-sync-cc.log";
      };
    };
  };
}
