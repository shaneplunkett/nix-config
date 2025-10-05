{ pkgs, ... }:
{
  plugins = {
    trouble = {
      enable = true;
      settings = {
        multiline = true;
      };
    };
  };
}
