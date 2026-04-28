{
  config,
  pkgs,
  ...
}:
let
  tokenPath = config.age.secrets.langsmith-api.path;

  envLoader = ''
    --run '
    if [ -r "${tokenPath}" ]; then
      export LANGSMITH_API_KEY="''${LANGSMITH_API_KEY:-$(<"${tokenPath}")}"
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
      description = "langsmith-cli wrapped to auto-load LANGSMITH_API_KEY from agenix";
    };
  };
in
{
  home.packages = [ langsmithCliWrapped ];
}
