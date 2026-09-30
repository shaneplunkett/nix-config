{ inputs, rootPath }:
let
  inherit (inputs)
    nixvim
    catppuccin
    vex-tooling
    nix-index-database
    ;

  # Single constructor for the project package set in pkgs/. The platform is
  # passed as a system string so the overlay can derive it from prev (avoiding
  # recursion through final.stdenv) while the flake packages output passes the
  # forAllSystems value.
  mkProjectPackages =
    system: pkgs:
    import (rootPath + /pkgs) {
      inherit pkgs;
      vexCodeSrc = inputs.vex-code;
      isLinux = inputs.nixpkgs.lib.hasSuffix "-linux" system;
      isX86Linux = system == "x86_64-linux";
    };
  palette = import ./palette.nix;
in
{
  inherit mkProjectPackages palette;

  mkOverlays =
    extras:
    [
      (
        _final: prev:
        let
          system = prev.stdenv.hostPlatform.system;
          aiPackages = inputs.llm-agents.packages.${system} or { };
          codexBase = aiPackages.codex;
          # Codex 0.159 starts the app-server daemon by default. The source
          # package from llm-agents still installs the CLI binaries without the
          # canonical package manifest/layout, so daemon bootstrap cannot copy
          # a complete local package and exits after the TUI opens.
          #
          # Keep the cache-backed build and finish its package layout locally.
          # This can go away once llm-agents ships codex-package.json plus the
          # required codex-path and codex-resources files itself.
          codex =
            prev.runCommand "${codexBase.name}-complete-package"
              {
                inherit (codexBase) version meta;
                passthru = codexBase.passthru or { };
              }
              ''
                mkdir -p "$out"
                cp -a ${codexBase}/. "$out/"
                chmod -R u+w "$out"

                ${
                  if prev.stdenv.hostPlatform.isLinux then
                    ''
                      package_root="$out/libexec/codex"
                      substituteInPlace "$out/bin/codex" \
                        --replace-fail ${codexBase} "$out"
                    ''
                  else
                    ''
                      package_root="$out/libexec/codex"
                      install -d "$package_root/bin"
                      for binary in codex codex-code-mode-host logs_client; do
                        if [ -e "$out/bin/$binary" ]; then
                          mv "$out/bin/$binary" "$package_root/bin/$binary"
                          ln -s "../libexec/codex/bin/$binary" "$out/bin/$binary"
                        fi
                      done
                    ''
                }

                install -d "$package_root/codex-path" "$package_root/codex-resources"
                install -m755 ${prev.ripgrep}/bin/rg "$package_root/codex-path/rg"
                ${prev.lib.optionalString prev.stdenv.hostPlatform.isLinux ''
                  rm -f "$package_root/codex-resources/bwrap"
                  install -m755 ${prev.bubblewrap}/bin/bwrap "$package_root/codex-resources/bwrap"
                ''}

                cat > "$package_root/codex-package.json" <<'EOF'
                ${builtins.toJSON {
                  layoutVersion = 1;
                  inherit (codexBase) version;
                  target = prev.stdenv.hostPlatform.config;
                  variant = "codex";
                  entrypoint = "bin/codex";
                  resourcesDir = "codex-resources";
                  pathDir = "codex-path";
                }}
                EOF

                test -x "$package_root/bin/codex"
                test -x "$package_root/bin/codex-code-mode-host"
                test -x "$package_root/codex-path/rg"
                ${prev.lib.optionalString prev.stdenv.hostPlatform.isLinux ''
                  test -x "$package_root/codex-resources/bwrap"
                ''}
              '';
        in
        (prev.lib.optionalAttrs (builtins.hasAttr "codex" aiPackages) {
          inherit codex;
        })
        // (prev.lib.optionalAttrs (builtins.hasAttr "claude-code" aiPackages) {
          inherit (aiPackages) claude-code;
        })
        // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
          # Keep Numtide's runtime wrappers and cache-backed derivations intact.
          inherit (aiPackages) chatgpt claude-desktop;
        }
      )
      (final: prev: mkProjectPackages prev.stdenv.hostPlatform.system final)
      (
        final: prev:
        let
          electron = inputs.electron-nixpkgs.legacyPackages.${final.stdenv.hostPlatform.system}.electron_43;
        in
        {
          bitwarden-desktop =
            (prev.bitwarden-desktop.override {
              electron_43 = electron;
            }).overrideAttrs
              (old: {
                # Apple's ld from cctools 1010.6 traps while processing stubs for
                # Bitwarden's desktop_napi dylib on aarch64-darwin. Use LLVM's
                # Mach-O linker for the Rust outputs until nixpkgs updates ld.
                nativeBuildInputs =
                  old.nativeBuildInputs ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [ final.lld ];
                env =
                  old.env
                  // final.lib.optionalAttrs final.stdenv.hostPlatform.isDarwin {
                    RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
                  };
                # Upstream pins an older Electron 43. Update the manifest after npmDeps
                # has been assembled so nixpkgs' runtime-major check accepts the
                # maintained Electron used by electron-builder.
                preBuild = ''
                  substituteInPlace package.json \
                    --replace-fail '"electron": "43.2.0"' '"electron": "${electron.version}"'
                ''
                + old.preBuild;
              });
        }
      )
      vex-tooling.overlays.default
    ]
    ++ extras;

  mkHomeManagerModule =
    {
      homeConfig,
      extraSpecialArgs ? { },
      extraSharedModules ? [ ],
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs palette;
        }
        // extraSpecialArgs;
        users.shane = import homeConfig;
        sharedModules = [
          nixvim.homeModules.nixvim
          catppuccin.homeModules.catppuccin
          (
            { lib, ... }:
            {
              catppuccin.autoEnable = lib.mkDefault false;
            }
          )
          nix-index-database.homeModules.nix-index
        ]
        ++ extraSharedModules;
      };
    };
}
