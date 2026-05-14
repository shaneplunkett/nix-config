{
  pkgs,
  ...
}:
let
  envLoader = ''
    --run '
    if [ -z "''${BROWSERBASE_API_KEY:-}" ]; then
      BROWSERBASE_API_KEY="$(${pkgs.rbw}/bin/rbw get browserbase-api-key 2>/dev/null)"
      [ -n "$BROWSERBASE_API_KEY" ] && export BROWSERBASE_API_KEY
    fi
    '
  '';

  browserbaseCliWrapped = pkgs.symlinkJoin {
    name = "browserbase-cli-wrapped-${pkgs.browserbase-cli.version}";
    paths = [ pkgs.browserbase-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/bb
      makeWrapper ${pkgs.browserbase-cli}/bin/bb $out/bin/bb ${envLoader}
    '';
    meta = pkgs.browserbase-cli.meta // {
      description = "browserbase-cli wrapped to auto-load BROWSERBASE_API_KEY from rbw";
    };
  };
in
{
  home.packages = [ browserbaseCliWrapped ];
}
