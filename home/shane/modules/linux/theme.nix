{ pkgs, ... }:

{
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders;
      iconTheme = "Papirus-Dark";


    };

  };


}
