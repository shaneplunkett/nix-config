{ ... }:
{
  homebrew = {
    enable = true;
    casks = [
      "zen"
      "ghostty"
      "figma"
      "ferdium"
    ];
    onActivation.cleanup = "zap";
  };
}
