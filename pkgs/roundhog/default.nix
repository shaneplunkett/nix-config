{
  lib,
  stdenvNoCC,
  fetchurl,
  python3Packages,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "roundhog";
  version = "0.12.3";

  # RoundHog ships inside PostHog's brand package as woff2 only.
  src = fetchurl {
    url = "https://registry.npmjs.org/@posthog/brand/-/brand-${finalAttrs.version}.tgz";
    hash = "sha256-qUvyW7Kkt5ooj5lwidvFTwaIJxwQZH5815lCiq1hXcs=";
  };

  nativeBuildInputs = [
    python3Packages.fonttools
    python3Packages.brotli
  ];

  # macOS can't install woff2, so decompress to TTF for both platforms.
  buildPhase = ''
    runHook preBuild
    for f in dist/fonts/*.woff2; do
      fonttools ttLib.woff2 decompress "$f" -o "''${f%.woff2}.ttf"
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 dist/fonts/*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "PostHog's rounded brand typeface";
    homepage = "https://posthog.com";
    # PolyForm Strict 1.0.0: personal use only, no redistribution.
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
