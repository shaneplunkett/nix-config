{
  config,
  pkgs,
  inputs,
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
}
