{
  config,
  pkgs,
  ...
}:
let
  tokenPath = config.age.secrets.browserbase-api-key.path;

  envLoader = ''
    --run '
    if [ -r "${tokenPath}" ]; then
      export BROWSERBASE_API_KEY="''${BROWSERBASE_API_KEY:-$(<"${tokenPath}")}"
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
      description = "browserbase-cli wrapped to auto-load BROWSERBASE_API_KEY from agenix";
    };
  };
in
{
  home.packages = [ browserbaseCliWrapped ];
}
