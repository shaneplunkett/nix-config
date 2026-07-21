{
  claude-code-latest,
  codex-patched,
  fetchPnpmDeps,
  lib,
  lsof,
  pnpm_11,
  src,
  stdenv,
  t3code,
}:

let
  pnpm = pnpm_11.override {
    version = "11.10.0";
    hash = "sha256-YgtmBepPYvxWptCphzP0eQcdAyHgPkhrUix+mnRhdDE=";
  };
in
(t3code.override {
  claude-code = claude-code-latest;
  codex = codex-patched;
  enableClaude = true;
  pnpm_10 = pnpm;
}).overrideAttrs
  (
    finalAttrs: previousAttrs: {
      pname = "vex-code";
      version = "0.0.29-vex.0";
      inherit src;

      pnpmDeps = fetchPnpmDeps {
        inherit pnpm;
        inherit (finalAttrs)
          pname
          version
          src
          pnpmWorkspaces
          ;
        fetcherVersion = 4;
        hash = "sha256-JmOs6j0Tx8EgZFgvYhhnIPLmEcXirk0AlLvY+onNZhQ=";
      };

      postPatch =
        (previousAttrs.postPatch or "")
        + ''
          # pnpm 11 defaults this to "install", which tries to repair the
          # workspace over the network when the build script starts.
          substituteInPlace pnpm-workspace.yaml \
            --replace-fail "packages:" $'verifyDepsBeforeRun: false\n\npackages:'
        ''
        + lib.optionalString stdenv.hostPlatform.isDarwin ''
          # Node 24/libuv can abort in kqueue when pnpm rebuilds several native
          # workspaces at once on Darwin. Serialising that rebuild avoids it.
          substituteInPlace pnpm-workspace.yaml \
            --replace-fail "verifyDepsBeforeRun: false" \
                           $'verifyDepsBeforeRun: false\nchildConcurrency: 1\nworkspaceConcurrency: 1'
        '';

      postFixup =
        (previousAttrs.postFixup or "")
        + ''
          wrapProgram "$out/bin/t3" \
            --prefix PATH : ${lib.makeBinPath [ lsof ]}
          wrapProgram "$out/bin/t3code-desktop" \
            --prefix PATH : ${lib.makeBinPath [ lsof ]} \
            --set T3CODE_DISABLE_AUTO_UPDATE 1
        ''
        + lib.optionalString stdenv.hostPlatform.isDarwin ''
          old_app="$out/Applications/T3 Code (Alpha).app"
          vex_app="$out/Applications/Vex Code (Alpha).app"
          old_executable="$old_app/Contents/MacOS/T3 Code (Alpha)"
          vex_executable="$old_app/Contents/MacOS/Vex Code (Alpha)"
          info_plist="$old_app/Contents/Info.plist"

          substituteInPlace "$info_plist" \
            --replace-fail \
              '<string>T3 Code (Alpha)</string>' \
              '<string>Vex Code (Alpha)</string>'
          mv "$old_executable" "$vex_executable"
          install -m 444 ${src}/apps/desktop/resources/icon.icns \
            "$old_app/Contents/Resources/t3code.icns"
          mv "$old_app" "$vex_app"
        '';

      meta = previousAttrs.meta // {
        description = "Shane's personal fork of T3 Code";
        homepage = "https://github.com/shaneplunkett/vex-code";
        downloadPage = "https://github.com/shaneplunkett/vex-code";
        changelog = null;
      };
    }
  )
