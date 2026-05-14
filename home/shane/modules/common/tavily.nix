{
  pkgs,
  ...
}:
let
  envLoader = ''
    --run '
    if [ -z "''${TAVILY_API_KEY:-}" ]; then
      TAVILY_API_KEY="$(${pkgs.rbw}/bin/rbw get tavily-api-key 2>/dev/null)"
      [ -n "$TAVILY_API_KEY" ] && export TAVILY_API_KEY
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
      description = "tavily-cli (tvly) wrapped to auto-load TAVILY_API_KEY from rbw";
    };
  };
in
{
  home.packages = [ tavilyCliWrapped ];
}
