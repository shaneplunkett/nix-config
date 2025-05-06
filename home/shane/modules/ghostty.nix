{...}: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-size = "16";
      command = "/home/shane/.nix-profile/bin/fish --login --interactive";
    };
  };
}
