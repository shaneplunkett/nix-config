{ ... }:
let
  colours = import ./theme/colours.nix;
in
{
  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      theme:
        activeBorderColor:
          - '#${colours.mauve}'
          - bold
        inactiveBorderColor:
          - '#${colours.subtext0}'
        optionsTextColor:
          - '#${colours.blue}'
        selectedLineBgColor:
          - '#${colours.surface0}'
        cherryPickedCommitBgColor:
          - '#${colours.surface1}'
        cherryPickedCommitFgColor:
          - '#${colours.mauve}'
        unstagedChangesColor:
          - '#${colours.red}'
        defaultFgColor:
          - '#${colours.text}'
        searchingActiveBorderColor:
          - '#${colours.yellow}'
      authorColors:
        '*': '#${colours.lavender}'
    git:
      overrideGpg: true
  '';
}
