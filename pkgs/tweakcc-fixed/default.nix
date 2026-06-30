# tweakcc-fixed — patcher for Claude Code's bundled binary.
#
# skrabe/tweakcc-fixed is a fork of Piebald-AI/tweakcc carrying cherry-picked
# upstream PRs plus skrabe-only features: system-reminder override mechanism,
# MCP per-server instruction routing, Skills view, regex updates for CC
# 2.1.113/126/142/183 minified shapes, and `claudemdContextOncePerConversation`.
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
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  autoPatchelfHook,
  makeBinaryWrapper,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tweakcc-fixed";
  # Keep on skrabe's releases: upstream Piebald-AI/tweakcc still lags
  # Claude Code version churn, and this fork carries the prompt/reminder
  # patching features this config depends on.
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "skrabe";
    repo = "tweakcc-fixed";
    rev = "59b408e0b3d8101d5d87e7c93c0c2a854e69173b";
    hash = "sha256-GsNM3hEtobVJsqEbx2lXpv1pcvjQo88Ghf6WCYUfZPs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-g1lOWbUNCBtsb/AUjB5uKcjNegk0B2gtllnw4YAyDf0=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
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

  postPatch = ''
    # In Nix, tweakcc patches the inner .claude-wrapped Bun binary before the
    # final wrapper/fixup environment exists. Keep Nix's versionCheckHook as the
    # real installed-binary check instead of failing on tweakcc's pre-fixup probe.
    substituteInPlace src/patches/index.ts \
      --replace-fail "      assertNativeBinaryStarts(tempBinaryPath);" "      // Nix runs the final installed-binary sanity check after fixup."
  '';

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
