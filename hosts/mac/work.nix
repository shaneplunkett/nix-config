{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common/macsettings.nix
    ./common/aerospace.nix
    ./common/fonts.nix
    ./common/user.nix
    ./common/packages.nix
    ./common/homebrew.nix
    ./common/fish.nix
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

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}
