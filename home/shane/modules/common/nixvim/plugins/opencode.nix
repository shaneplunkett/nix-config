{ pkgs, ... }:
{

  plugins = {

    opencode = {
      enable = true;
      settings = {
        input.enabled = true;

      };

    };

  };
}
