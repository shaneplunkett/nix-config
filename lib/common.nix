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
          hasCliPackages = builtins.hasAttr "claude-code" aiPackages && builtins.hasAttr "codex" aiPackages;
        in
        (prev.lib.optionalAttrs hasCliPackages {
          inherit (aiPackages) claude-code codex;
        })
        // (prev.lib.optionalAttrs (
          prev.stdenv.hostPlatform.isLinux && builtins.hasAttr "claude-desktop" aiPackages
        ) {
          # ANGLE dlopens the native libEGL.so.1 from inside a bundled shared
          # library, where upstream's runtimeDependencies RUNPATH (executables
          # only) doesn't reach, so GPU init fails and the UI falls back to
          # software rendering. Put glvnd on LD_LIBRARY_PATH, which dlopen
          # always searches.
          claude-desktop = aiPackages.claude-desktop.overrideAttrs (old: {
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/claude-desktop \
                --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [ prev.libglvnd ]}
            '';
          });
        })
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
              electron_39 = electron;
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
                # Upstream still pins Electron 39. Update the manifest after npmDeps
                # has been assembled so nixpkgs' runtime-major check accepts the
                # maintained Electron used by electron-builder.
                preBuild = ''
                  substituteInPlace package.json \
                    --replace-fail '"electron": "39.8.5"' '"electron": "${electron.version}"'
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
