{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      gcloud = {
        format = "on [$symbol$account(@$domain) ($project)]($style) ";
        detect_env_vars = [ "GOOGLE" ];
      };
    };
  };
}
