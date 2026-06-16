{ ... }:
{
  imports = [
    ../shane/modules/common/ai/hermes
  ];

  home = {
    username = "vex";
    homeDirectory = "/Users/vex";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
