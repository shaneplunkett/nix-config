{ config, pkgs, ... }:

{
  imports = [ ../common-macos.nix ];

  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    mkalias
    alt-tab-macos
    home-manager
    raycast
    ytmdesktop
  ];
  users.users.shane.home = "/Users/shane";

  home-manager.backupFileExtension = "backup";

  programs.fish.enable = true;

  # Enable experimental Nix features
  nix.settings.experimental-features = "nix-command flakes";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # macOS system settings
  system = {
    activationScripts.applications.text =
      let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
      pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';
  };

  #Homebrew
  homebrew = {
    enable = true;
    casks = [
      "figma"
      "slack"
    ];
    masApps = {
      "Word" = 462054704;
      "Excel" = 462058435;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

  };

  # State version for nix-darwin; leave as an integer
  system.stateVersion = 6;
}
