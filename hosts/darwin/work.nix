{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  homebrew.casks = lib.mkAfter [
    "slack"
    "figma"
  ];

  homebrew.masApps = {
    "Word" = 462054704;
    "Excel" = 462058435;
  };

  environment.systemPackages = lib.mkAfter [
    (pkgs.jetbrains.datagrip.overrideAttrs {
      version = "2024.3.5";
      src = pkgs.fetchurl {
        url = "https://download.jetbrains.com/datagrip/datagrip-2024.3.5-aarch64.dmg";
        sha256 = "1ba33de8b5595a7ab3ab683ed21200c6c884c7c9299a9dfe4414ae29b219dc09";
      };
    })
  ];

  home-manager.backupFileExtension = "backup";

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}
