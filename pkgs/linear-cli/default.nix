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

    buildPhase = ''
      runHook preBuild

      export DENO_DIR="$TMPDIR/deno-dir"
      export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
      mkdir -p "$DENO_DIR"
      deno cache "${jsrPackage}"
      find "$DENO_DIR" -maxdepth 1 -type f -delete

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R "$DENO_DIR"/. "$out/"

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-5qHRpT1aOYRruKaMHxtj5I9J1ouyCLbovkKayA4wDBg=";
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
      --set DENO_DIR "${denoDeps}" \
      --set DENO_NO_UPDATE_CHECK 1 \
      --add-flags "run --cached-only --allow-all --quiet ${jsrPackage}"
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
