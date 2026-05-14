{
  pkgs,
  ...
}:
let
  envLoader = ''
    --run '
    if [ -z "''${TODOIST_API_TOKEN:-}" ]; then
      TODOIST_API_TOKEN="$(${pkgs.rbw}/bin/rbw get todoist-api-token 2>/dev/null)"
      [ -n "$TODOIST_API_TOKEN" ] && export TODOIST_API_TOKEN
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
      description = "todoist-cli wrapped to auto-load TODOIST_API_TOKEN from rbw";
    };
  };
in
{
  home.packages = [ todoistCliWrapped ];
}
