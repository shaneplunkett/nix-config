{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  idPath = config.age.secrets.vex-cli-cf-id.path;
  secretPath = config.age.secrets.vex-cli-cf-secret.path;

  vexCli = inputs.vex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;

  envLoader = ''
    --run '
    if [ -r "${idPath}" ] && [ -r "${secretPath}" ]; then
      export CF_ACCESS_CLIENT_ID="''${CF_ACCESS_CLIENT_ID:-$(<"${idPath}")}"
      export CF_ACCESS_CLIENT_SECRET="''${CF_ACCESS_CLIENT_SECRET:-$(<"${secretPath}")}"
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
      description = "vex Go CLI wrapped to auto-load CF Access service token from agenix";
    };
  };

  # `vex-env <cmd> [args...]` — exports the CF Access headers + endpoint and
  # exec's the command. Useful as a primitive (e.g. `vex-env curl
  # "$VEX_API_ENDPOINT/v1/recall"`) and for debugging the env plumbing.
  vexEnv = pkgs.writeShellScriptBin "vex-env" ''
    set -e
    if [ -r "${idPath}" ] && [ -r "${secretPath}" ]; then
      export CF_ACCESS_CLIENT_ID="''${CF_ACCESS_CLIENT_ID:-$(<"${idPath}")}"
      export CF_ACCESS_CLIENT_SECRET="''${CF_ACCESS_CLIENT_SECRET:-$(<"${secretPath}")}"
    else
      echo "vex-env: agenix secrets unreadable (id=${idPath} secret=${secretPath})" >&2
      exit 1
    fi
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
  # Access service token + endpoint from agenix before invoking vex.

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
        # Catch up if the machine was asleep at the scheduled fire time.
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
        # Hourly cadence; launchd will fire missed runs after wake.
        StartInterval = 3600;
        # Don't fire immediately at agent load — give the network a moment.
        RunAtLoad = false;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/vex-sync-cc.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/vex-sync-cc.log";
      };
    };
  };
}
