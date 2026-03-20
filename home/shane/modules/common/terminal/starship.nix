{ ... }:
let
  c = import ../theme/colours.nix;
  h = colour: "#${colour}";
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      directory = {
        style = "bold ${h c.teal}";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      character = {
        success_symbol = "[❯](${h c.green})";
        error_symbol = "[❯](${h c.red})";
      };

      git_branch = {
        style = h c.mauve;
        symbol = " ";
      };

      git_status = {
        style = h c.peach;
        modified = "!";
        staged = "+";
        untracked = "?";
      };

      cmd_duration = {
        style = h c.yellow;
        min_time = 2000;
      };

      nix_shell = {
        style = h c.sky;
        symbol = " ";
      };

      golang = {
        style = h c.sky;
        symbol = " ";
      };

      nodejs = {
        style = h c.green;
        symbol = " ";
      };

      python = {
        style = h c.yellow;
        symbol = " ";
      };

      rust = {
        style = h c.peach;
        symbol = "󱘗 ";
      };

      terraform = {
        style = h c.lavender;
        symbol = "󱁢 ";
      };

      gcloud = {
        format = "on [$symbol$account(@$domain) ($project)]($style) ";
        detect_env_vars = [ "GOOGLE" ];
        style = h c.teal;
      };
    };
  };
}
