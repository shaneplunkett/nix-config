{
  cacert,
  deno,
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenvNoCC,
}:
let
  version = "2.1.1";
  jsrPackage = "jsr:@schpet/linear-cli@${version}";
  denoConfig = ./deno.json;
  denoLock = ./deno.lock;

  src = fetchFromGitHub {
    owner = "schpet";
    repo = "linear-cli";
    tag = "v${version}";
    hash = "sha256-aiTHUH0mxhGSnH7kmsVTk2TsXe5SbXcsawVOqUPbd/o=";
  };

  denoDeps = stdenvNoCC.mkDerivation {
    pname = "linear-cli-deno-deps";
    inherit version;

    nativeBuildInputs = [ deno ];

    dontUnpack = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export DENO_DIR="$TMPDIR/deno-dir"
      export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
      mkdir -p "$DENO_DIR"
      cp ${denoConfig} deno.json
      cp ${denoLock} deno.lock
      deno install --vendor --frozen --entrypoint "${jsrPackage}"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp deno.json deno.lock "$out/"
      cp -R vendor node_modules "$out/"

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-bFX6Lli74/mhXgt55IcWse/WcySzdbkLwYnsw5HolvE=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "linear-cli";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    makeWrapper ${lib.getExe deno} "$out/bin/linear" \
      --set DENO_NO_UPDATE_CHECK 1 \
      --add-flags "run --cached-only --frozen --vendor --config ${denoDeps}/deno.json --lock ${denoDeps}/deno.lock --allow-all --quiet ${jsrPackage}"
    install -Dm644 LICENSE "$out/share/licenses/linear-cli/LICENSE"

    runHook postInstall
  '';

  meta = {
    description = "Linear issue tracking from the command line";
    homepage = "https://github.com/schpet/linear-cli";
    changelog = "https://github.com/schpet/linear-cli/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.isc;
    mainProgram = "linear";
    platforms = lib.platforms.unix;
  };
}
