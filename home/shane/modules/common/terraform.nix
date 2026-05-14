{ config, ... }:
{
  # Shared plugin cache across every Terraform repo on disk — one download
  # per provider+version instead of N. Massive `terraform init` speedup on a
  # machine with 20+ TF repos.
  home.sessionVariables = {
    TF_PLUGIN_CACHE_DIR = "${config.home.homeDirectory}/.terraform.d/plugin-cache";
  };

  # Fish doesn't always inherit home.sessionVariables on interactive launches,
  # so mirror it here for shell sessions.
  programs.fish.interactiveShellInit = ''
    set -gx TF_PLUGIN_CACHE_DIR $HOME/.terraform.d/plugin-cache
  '';

  # Terraform refuses to use the cache dir unless it already exists.
  home.file.".terraform.d/plugin-cache/.keep".text = "";
}
