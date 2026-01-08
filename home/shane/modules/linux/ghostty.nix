{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      font-size = "16";
      command = "fish --login --interactive";
      theme = "Catppuccin Mocha";
      confirm-close-surface = "false";

    };
  };
}
