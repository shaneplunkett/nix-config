{
  lib,
  fetchurl,
  stdenv,
  stdenvNoCC,
  unzip,
  makeWrapper,
  patchelf,
  glibc,
}:
let
  version = "0.4.4";

  assetBySystem = {
    aarch64-darwin = "coderabbit-darwin-arm64.zip";
    x86_64-darwin = "coderabbit-darwin-x64.zip";
    aarch64-linux = "coderabbit-linux-arm64.zip";
    x86_64-linux = "coderabbit-linux-x64.zip";
  };

  hashBySystem = {
    aarch64-darwin = "sha256-+8Uf+GXdcbTwhRGUn3wOOiOs0t1u7GwC6bgayjgmYm8=";
    x86_64-darwin = "sha256-4y+JnIM5c8R1IYw2iNAtQ91OGEd8I7Xqe5Wwz0FAJ+U=";
    aarch64-linux = "sha256-5yyAYemBkFaU+n1IYDyKPcC31nB/AUCIneavsRm08gw=";
    x86_64-linux = "sha256-BBZbcglgXN6pMhHXlJw+RKraizCS+2zoBPm5aVqzgnM=";
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assetBySystem.${system} or (throw "coderabbit-cli: unsupported system '${system}'");
  hash = hashBySystem.${system} or (throw "coderabbit-cli: missing hash for '${system}'");
in
stdenvNoCC.mkDerivation {
  pname = "coderabbit-cli";
  inherit version;

  src = fetchurl {
    url = "https://cli.coderabbit.ai/releases/${version}/${asset}";
    inherit hash;
  };

  nativeBuildInputs =
    [ unzip ]
    ++ lib.optionals stdenv.isLinux [
      patchelf
      makeWrapper
    ];

  # Bun SEA binaries embed a payload that the runtime reads from the file tail.
  # autoPatchelfHook rewrites ELF segments and breaks SEA detection — instead we
  # only patch the interpreter (PT_INTERP) and provide libs via LD_LIBRARY_PATH.
  dontStrip = true;
  dontPatchELF = true;

  unpackPhase = ''
    runHook preUnpack
    unzip "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 coderabbit "$out/bin/.coderabbit-unwrapped"
  ''
  + lib.optionalString stdenv.isLinux ''
    patchelf \
      --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
      "$out/bin/.coderabbit-unwrapped"
    makeWrapper "$out/bin/.coderabbit-unwrapped" "$out/bin/coderabbit" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          glibc
          stdenv.cc.cc.lib
        ]
      }"
  ''
  + lib.optionalString stdenv.isDarwin ''
    mv "$out/bin/.coderabbit-unwrapped" "$out/bin/coderabbit"
  ''
  + ''
    ln -s coderabbit "$out/bin/cr"
    runHook postInstall
  '';

  meta = {
    description = "CodeRabbit CLI — local AI code reviews from the terminal";
    homepage = "https://docs.coderabbit.ai/cli";
    license = lib.licenses.unfree;
    platforms = builtins.attrNames assetBySystem;
    mainProgram = "coderabbit";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
