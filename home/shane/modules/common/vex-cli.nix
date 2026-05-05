{
  config,
  pkgs,
  ...
}:
let
  idPath = config.age.secrets.vex-cli-cf-id.path;
  secretPath = config.age.secrets.vex-cli-cf-secret.path;

  # Same pattern as atlassian.nix / langsmith.nix — when the Go `vex` CLI lands
  # in this nix tree, swap `vexCliWrapped` in to wrap it with this loader.
  envLoader = ''
    --run '
    if [ -r "${idPath}" ] && [ -r "${secretPath}" ]; then
      export CF_ACCESS_CLIENT_ID="''${CF_ACCESS_CLIENT_ID:-$(<"${idPath}")}"
      export CF_ACCESS_CLIENT_SECRET="''${CF_ACCESS_CLIENT_SECRET:-$(<"${secretPath}")}"
    fi
    export VEX_API_ENDPOINT="''${VEX_API_ENDPOINT:-https://vex.shaneplunkett.dev}"
    '
  '';

  # `vex-env <cmd> [args...]` — exports the CF Access headers + endpoint and
  # exec's the command. Useful as a stop-gap until the Go CLI ships, and as a
  # primitive afterwards (e.g. `vex-env curl "$VEX_API_ENDPOINT/v1/recall"`).
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

  # `vex` — convenience POST wrapper around the /v1/* RPC surface.
  # Usage: vex <tool-name> [json-body]
  #   vex boot
  #   vex recall '{"query":"agenix wiring","limit":3}'
  # Will be supplanted by the Go CLI but keeps the loop tight in the meantime.
  vexHelper = pkgs.writeShellScriptBin "vex" ''
    set -e
    if [ $# -lt 1 ]; then
      echo "usage: vex <tool-name> [json-body]" >&2
      exit 2
    fi
    tool="$1"
    body="''${2:-{\}}"
    if [ -r "${idPath}" ] && [ -r "${secretPath}" ]; then
      CF_ACCESS_CLIENT_ID="''${CF_ACCESS_CLIENT_ID:-$(<"${idPath}")}"
      CF_ACCESS_CLIENT_SECRET="''${CF_ACCESS_CLIENT_SECRET:-$(<"${secretPath}")}"
    else
      echo "vex: agenix secrets unreadable" >&2
      exit 1
    fi
    endpoint="''${VEX_API_ENDPOINT:-https://vex.shaneplunkett.dev}"
    exec ${pkgs.curl}/bin/curl -sS \
      -H "CF-Access-Client-Id: $CF_ACCESS_CLIENT_ID" \
      -H "CF-Access-Client-Secret: $CF_ACCESS_CLIENT_SECRET" \
      -H "content-type: application/json" \
      -X POST \
      --data "$body" \
      "$endpoint/v1/$tool"
  '';
in
{
  home.packages = [
    vexEnv
    vexHelper
  ];
}
