{
  config,
  pkgs,
  ...
}:
let
  cifPath = config.age.secrets.ing-cif.path;
  codePath = config.age.secrets.ing-access-code.path;
  acctPath = config.age.secrets.ing-account-number.path;

  # `ing-env [cmd args...]` — exports ING_CIF / ING_ACCESS_CODE /
  # ING_ACCOUNT_NUMBER from agenix and exec's the command. With no args,
  # prints the env vars (redacted) so you can sanity-check the plumbing.
  ingEnv = pkgs.writeShellScriptBin "ing-env" ''
    set -e
    if [ -r "${cifPath}" ] && [ -r "${codePath}" ] && [ -r "${acctPath}" ]; then
      export ING_CIF="''${ING_CIF:-$(<"${cifPath}")}"
      export ING_ACCESS_CODE="''${ING_ACCESS_CODE:-$(<"${codePath}")}"
      export ING_ACCOUNT_NUMBER="''${ING_ACCOUNT_NUMBER:-$(<"${acctPath}")}"
    else
      echo "ing-env: agenix secrets unreadable (cif=${cifPath} code=${codePath} acct=${acctPath})" >&2
      exit 1
    fi

    if [ $# -eq 0 ]; then
      printf 'ING_CIF=%s***\nING_ACCESS_CODE=****\nING_ACCOUNT_NUMBER=%s***\n' \
        "''${ING_CIF:0:2}" "''${ING_ACCOUNT_NUMBER:0:2}"
      exit 0
    fi
    exec "$@"
  '';

  # `ing-probe` — runs the puppeteer login + ExportTransactions probe
  # at ~/projects/personal/ing-probe/probe.mjs with creds from agenix.
  # Exits non-zero if creds are unreadable or the probe directory is missing.
  ingProbe = pkgs.writeShellScriptBin "ing-probe" ''
    set -e
    PROBE_DIR="$HOME/projects/personal/ing-probe"
    if [ ! -f "$PROBE_DIR/probe.mjs" ]; then
      echo "ing-probe: $PROBE_DIR/probe.mjs not found" >&2
      exit 1
    fi
    if [ -r "${cifPath}" ] && [ -r "${codePath}" ] && [ -r "${acctPath}" ]; then
      export ING_CIF="$(<"${cifPath}")"
      export ING_ACCESS_CODE="$(<"${codePath}")"
      export ING_ACCOUNT_NUMBER="$(<"${acctPath}")"
    else
      echo "ing-probe: agenix secrets unreadable" >&2
      exit 1
    fi
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
