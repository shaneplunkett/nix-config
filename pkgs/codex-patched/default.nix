{
  lib,
  stdenv,
  codex,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  bubblewrap,
  clang,
  cmake,
  gitMinimal,
  libcap,
  libclang,
  librusty_v8 ? codex.RUSTY_V8_ARCHIVE,
  livekit-libwebrtc,
  makeBinaryWrapper,
  nix-update-script,
  pkg-config,
  openssl,
  ripgrep,
  versionCheckHook,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codex-patched";
  version = "0.139.0";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${finalAttrs.version}";
    hash = "sha256-XjzlkBUkBey+P3tFLDYB3ae5oseUfW5tmzhLzqlqj2E=";
  };

  sourceRoot = "${finalAttrs.src.name}/codex-rs";

  cargoHash = "sha256-8mN4OTRJvt2mBYHQXZS55PSOChLqEIiXwPu2y+2MZ9o=";

  patches = [
    ./codex-vex-markdown-colours.patch
  ];

  cargoBuildFlags = [
    "--package"
    "codex-cli"
  ];
  cargoCheckFlags = [
    "--package"
    "codex-cli"
  ];

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/webrtc-sys-*/build.rs \
      --replace-fail "cargo:rustc-link-lib=static=webrtc" "cargo:rustc-link-lib=dylib=webrtc"
    substituteInPlace Cargo.toml \
      --replace-fail 'lto = "thin"' "" \
      --replace-fail 'codegen-units = 1' ""
  '';

  nativeBuildInputs = [
    clang
    cmake
    gitMinimal
    installShellFiles
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    libclang
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
  ];

  env = {
    LIBCLANG_PATH = "${lib.getLib libclang}/lib";
    LK_CUSTOM_WEBRTC = lib.getDev livekit-libwebrtc;
    NIX_CFLAGS_COMPILE = toString (
      lib.optionals stdenv.cc.isGNU [
        "-Wno-error=stringop-overflow"
      ]
      ++ lib.optionals stdenv.cc.isClang [
        "-Wno-error=character-conversion"
      ]
    );
    RUSTY_V8_ARCHIVE = librusty_v8;
  };

  doCheck = false;

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  postFixup = ''
    wrapProgram $out/bin/codex --prefix PATH : ${
      lib.makeBinPath ([ ripgrep ] ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ])
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
        "--version-regex"
        "^rust-v(\\d+\\.\\d+\\.\\d+)$"
      ];
    };
  };

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    maintainers = with lib.maintainers; [
      delafthi
      jeafleohj
      malo
    ];
    platforms = lib.platforms.unix;
  };
})
