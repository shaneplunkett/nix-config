{
  config,
  pkgs,
  ...
}:
let
  tokenPath = config.age.secrets.huggingface.path;

  envLoader = ''
    --run '
    if [ -r "${tokenPath}" ]; then
      export HF_TOKEN="''${HF_TOKEN:-$(<"${tokenPath}")}"
    fi
    export MEETSCRIBE_SUMMARY_MODEL="''${MEETSCRIBE_SUMMARY_MODEL:-qwen2.5:7b}"
    '
  '';

  meetWrapped = pkgs.symlinkJoin {
    name = "meetscribe-wrapped";
    paths = [ pkgs.meetscribe ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/meet
      makeWrapper ${pkgs.meetscribe}/bin/meet $out/bin/meet ${envLoader}
    '';
    meta = pkgs.meetscribe.meta // {
      description = "meetscribe wrapped to auto-load HF_TOKEN from agenix";
    };
  };
in
{
  home.packages = [ meetWrapped ];
}
