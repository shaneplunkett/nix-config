{
  pkgs,
  ...
}:
let
  rbw = "${pkgs.rbw}/bin/rbw";

  # ING creds live in the existing `www.ing.com.au` Bitwarden entry as:
  #   username = CIF
  #   password = access-code
  #   notes    = account-number
  loadEnv = ''
    ING_CIF="$(${rbw} get --field username www.ing.com.au 2>/dev/null)"
    ING_ACCESS_CODE="$(${rbw} get www.ing.com.au 2>/dev/null)"
    ING_ACCOUNT_NUMBER="$(${rbw} get --raw www.ing.com.au 2>/dev/null | ${pkgs.jq}/bin/jq -r '.notes // empty')"
    if [ -z "$ING_CIF" ] || [ -z "$ING_ACCESS_CODE" ] || [ -z "$ING_ACCOUNT_NUMBER" ]; then
      echo "ing: unable to fetch ING creds from rbw (is the agent unlocked?)" >&2
      exit 1
    fi
    export ING_CIF ING_ACCESS_CODE ING_ACCOUNT_NUMBER
  '';

  ingEnv = pkgs.writeShellScriptBin "ing-env" ''
    set -e
    ${loadEnv}
    if [ $# -eq 0 ]; then
      printf 'ING_CIF=%s***\nING_ACCESS_CODE=****\nING_ACCOUNT_NUMBER=%s***\n' \
        "''${ING_CIF:0:2}" "''${ING_ACCOUNT_NUMBER:0:2}"
      exit 0
    fi
    exec "$@"
  '';

  ingProbe = pkgs.writeShellScriptBin "ing-probe" ''
    set -e
    PROBE_DIR="$HOME/projects/personal/ing-probe"
    if [ ! -f "$PROBE_DIR/probe.mjs" ]; then
      echo "ing-probe: $PROBE_DIR/probe.mjs not found" >&2
      exit 1
    fi
    ${loadEnv}
    cd "$PROBE_DIR"
    exec ${pkgs.nodejs}/bin/node probe.mjs
  '';
in
{
  home.packages = [
    ingEnv
    ingProbe
  ];
}
