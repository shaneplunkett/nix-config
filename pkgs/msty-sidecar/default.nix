{
  appimageTools,
  fetchurl,
  nodejs,
  nodePackages,
  uv,
  python3,
  makeWrapper,
}:
let
  pname = "msty-sidecar";
  version = "0.4.0";
  src = fetchurl {
    url = "https://sidecar-assets.msty.studio/prod/latest/linux/amd64/MstySidecar_x86_64_amd64.AppImage";
    sha256 = "sha256-UhsokCG0NPqn5nhn//AaIuY6sWlZkejNlqMEyN4Opqg=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  nativeBuildInputs = [ makeWrapper ];

  extraPkgs = pkgs: [
    nodejs
    nodePackages.npm
    uv
    python3
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/mstysidecar.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/mstysidecar.desktop \
            --replace 'Exec=AppRun' 'Exec=${pname}'
    install -m 444 -D ${appimageContents}/mstysidecar.png \
            $out/share/icons/hicolor/256x256/apps/mstysidecar.png
            wrapProgram $out/bin/${pname} \
                    --prefix PATH : ${nodejs}/bin:${nodePackages.npm}/bin:${uv}/bin:${python3}/bin
  '';
}
