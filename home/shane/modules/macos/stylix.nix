{ pkgs, ... }:
{

  stylix = {

    targets = {
      nixvim.enable = false;
      ghostty.enable = false;
      starship.enable = false;
      fish.enable = false;

    };
  };
}
