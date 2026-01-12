{ self, ... }:
{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";

      color_overrides = {
        mocha = {
          mantle = "#1e1e2e";
        };
      };
    };
  };
}
