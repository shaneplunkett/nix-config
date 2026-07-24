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
          vex-tooling.homeManagerModules.default
          nix-index-database.homeModules.nix-index
        ]
        ++ extraSharedModules;
      };
    };
}
