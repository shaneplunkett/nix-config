{
  fetchFromGitHub,
  nix-update-script,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "xcodebuild-nvim";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "wojciech-kulik";
    repo = "xcodebuild.nvim";
    rev = "v${version}";
    hash = "sha256-+GeZzPf9aFufvszUDCFX8Osp4202c6p2hOeI2vbjYrc=";
  };

  nvimRequireCheck = "xcodebuild";

  passthru.updateScript = nix-update-script { };
}
