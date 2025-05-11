{ ... }:
{
  homebrew = {
    enable = true;
    casks = [
      "zen"
      "ghostty"
      "figma"
    ];
    onActivation.cleanup = "zap";
  };
}
