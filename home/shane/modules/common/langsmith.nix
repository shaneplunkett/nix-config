{
  pkgs,
  ...
}:
let
  envLoader = ''
    --run '
    if [ -z "''${LANGSMITH_API_KEY:-}" ]; then
      LANGSMITH_API_KEY="$(${pkgs.rbw}/bin/rbw get langsmith-api-key 2>/dev/null)"
      [ -n "$LANGSMITH_API_KEY" ] && export LANGSMITH_API_KEY
    fi
    export LANGSMITH_ENDPOINT="''${LANGSMITH_ENDPOINT:-https://api.smith.langchain.com}"
    '
  '';

  langsmithCliWrapped = pkgs.symlinkJoin {
    name = "langsmith-cli-wrapped-${pkgs.langsmith-cli.version}";
    paths = [ pkgs.langsmith-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/langsmith
      makeWrapper ${pkgs.langsmith-cli}/bin/langsmith $out/bin/langsmith ${envLoader}
    '';
    meta = pkgs.langsmith-cli.meta // {
      description = "langsmith-cli wrapped to auto-load LANGSMITH_API_KEY from rbw";
    };
  };
in
{
  home.packages = [ langsmithCliWrapped ];
}
