# tweakcc-fixed — patcher for Claude Code's bundled binary.
#
# skrabe/tweakcc-fixed is a fork of Piebald-AI/tweakcc carrying cherry-picked
# upstream PRs plus skrabe-only features: system-reminder override mechanism,
# MCP per-server instruction routing, Skills view, regex updates for CC
# 2.1.113/126/142 minified shapes, and `claudemdContextOncePerConversation`.
# Upstream lags CC version churn by 2+ weeks; the fork is structural for
# current CC, not optional.
#
# Derivation faithfully adapted from github.com/typedrat/nix-config
# (packages/tweakcc-fixed.nix, MIT). Kept verbatim where possible so future
# upstream bumps land cleanly.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  autoPatchelfHook,
  makeBinaryWrapper,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tweakcc-fixed";
  # Tracking `main` until skrabe cuts a new tag. Latest tag predates the
  # Bun >=1.3 `.bun` ELF section support that CC 2.1.x ships with, so
  # native-binary extraction fails on `pkgs.claude-code` without these
  # commits.
  version = "4.0.11-unstable-2026-05-15";

  src = fetchFromGitHub {
    owner = "skrabe";
    repo = "tweakcc-fixed";
    rev = "1459a2c04729c2d157225edae3ed752b4061b8c8";
    hash = "sha256-dgqCFNJNU6mg0Z2FQceGZa0ugnRAt5IHdzkgfDpvyrE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 2;
    hash = "sha256-IECGektWlYDHY4Iljx5U5TJFLBiiT+kke6AgPIMnDgE=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeBinaryWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  # node-lief ships a prebuilt .node addon that dynamically links against
  # libstdc++ and libgcc_s. autoPatchelfHook needs the runtime libs in
  # buildInputs to rewrite the RPATH; without it the build sandbox can run
  # tweakcc-fixed once but consumers that load LIEF inside their own
  # sandbox (e.g. claude-code-patched) segfault on dlopen.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # node-lief also ships musl prebuilds we never load on glibc hosts.
  # node-gyp-build picks `.node` over `.musl.node` at runtime, so it's
  # safe to leave the musl-only libc dep unsatisfied.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  # Drop dev dependencies and non-deterministic / unnecessary files.
  preInstall = ''
    CI=true pnpm --ignore-scripts --prod prune
    find . -type f \( -name "*.ts" -not -name "*.d.ts" -o -name "*.map" \) -delete
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete
    rm -f node_modules/.modules.yaml
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/tweakcc-fixed $out/bin
    # `data/prompts/` is resolved at runtime; without it tweakcc-fixed
    # falls back to fetching from GitHub, which fails in offline contexts.
    cp -R dist node_modules package.json data $out/lib/tweakcc-fixed/
    makeBinaryWrapper ${lib.getExe nodejs} $out/bin/tweakcc-fixed \
      --add-flags "$out/lib/tweakcc-fixed/dist/index.mjs"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = {
    description = "Fork of tweakcc with cherry-picked upstream fixes plus skrabe-only system-reminder / MCP routing / claudemd-once features";
    homepage = "https://github.com/skrabe/tweakcc-fixed";
    changelog = "https://github.com/skrabe/tweakcc-fixed/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "tweakcc-fixed";
    platforms = lib.platforms.unix;
  };
})
