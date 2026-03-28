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
    customCommands:
      - key: "<c-a>"
        description: "AI commit message"
        command: 'git commit -m "{{.Form.Msg}}"'
        context: "files"
        prompts:
          - type: "menuFromCommand"
            title: "AI Commits"
            key: "Msg"
            command: "lazycommit commit"
            filter: '^(?P<raw>.+)$'
            valueFormat: "{{ .raw }}"
            labelFormat: "{{ .raw | green }}"
  '';

  xdg.configFile.".lazycommit.yaml".text = ''
    active_provider: anthropic
    providers:
      anthropic:
        model: "claude-haiku-4-5"
        num_suggestions: 10
  '';
}
