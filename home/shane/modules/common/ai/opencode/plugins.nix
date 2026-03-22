{ ... }:
{

  programs.opencode.settings.plugin = [
    "opencode-claude-auth"
    "@simonwjackson/opencode-direnv"
  ];

  xdg.configFile."opencode/plugins" = {
    source = ./plugins;
    recursive = true;
  };

}
