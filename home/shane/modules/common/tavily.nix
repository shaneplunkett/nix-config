{
  config,
  pkgs,
  ...
}:
let
  tokenPath = config.age.secrets.tavily-api-key.path;

  envLoader = ''
    --run '
    if [ -r "${tokenPath}" ]; then
      export TAVILY_API_KEY="''${TAVILY_API_KEY:-$(<"${tokenPath}")}"
    fi
    '
  '';

  tavilyCliWrapped = pkgs.symlinkJoin {
    name = "tavily-cli-wrapped-${pkgs.tavily-cli.version}";
    paths = [ pkgs.tavily-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/tvly
      makeWrapper ${pkgs.tavily-cli}/bin/tvly $out/bin/tvly ${envLoader}
    '';
    meta = pkgs.tavily-cli.meta // {
      description = "tavily-cli (tvly) wrapped to auto-load TAVILY_API_KEY from agenix";
    };
  };
in
{
  home.packages = [ tavilyCliWrapped ];
}
