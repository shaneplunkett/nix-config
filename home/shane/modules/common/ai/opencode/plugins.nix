{ ... }:
{

  programs.opencode.settings.plugin = [
    "@simonwjackson/opencode-direnv"
  ];

  xdg.configFile."opencode/plugins" = {
    source = ./plugins;
    recursive = true;
  };

  xdg.configFile."opencode/package.json".text = builtins.toJSON {
    dependencies = {
      "@openauthjs/openauth" = "latest";
      "proper-lockfile" = "latest";
    };
  };

}
