{
  codex,
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

  # nixpkgs splits t3code into an unwrapped pnpm build plus a symlinkJoin
  # wrapper that puts the enabled agent CLIs on PATH. The fork source, pnpm
  # swap, and branding belong on the unwrapped build; the agent toggles on
  # the wrapper.
  unwrapped =
    (t3code.unwrapped.override { pnpm_10 = pnpm; }).overrideAttrs
      (
        finalAttrs: previousAttrs: {
          pname = "vex-code-unwrapped";
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
            hash = "sha256-bfZDQjVdT0neQYxmNB8t+XU8mbjVsAtaTi2Vms5pzxw=";
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
      );
in
(t3code.override {
  inherit codex;
  enableClaude = true;
  t3code-unwrapped = unwrapped;
}).overrideAttrs
  { pname = "vex-code"; }
