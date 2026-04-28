{
  config,
  pkgs,
  ...
}:
let
  tokenPath = config.age.secrets.todoist.path;

  envLoader = ''
    --run '
    if [ -r "${tokenPath}" ]; then
      export TODOIST_API_TOKEN="''${TODOIST_API_TOKEN:-$(<"${tokenPath}")}"
    fi
    '
  '';

  todoistCliWrapped = pkgs.symlinkJoin {
    name = "todoist-cli-wrapped-${pkgs.todoist-cli.version}";
    paths = [ pkgs.todoist-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/td
      makeWrapper ${pkgs.todoist-cli}/bin/td $out/bin/td ${envLoader}
    '';
    meta = pkgs.todoist-cli.meta // {
      description = "todoist-cli wrapped to auto-load TODOIST_API_TOKEN from agenix";
    };
  };
in
{
  home.packages = [ todoistCliWrapped ];
}
