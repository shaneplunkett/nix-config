{ ... }:
{
  xdg.configFile."lazygit/config.yml".text = ''
    gui:
      theme:
        activeBorderColor:
          - '#cba6f7'
          - bold
        inactiveBorderColor:
          - '#a6adc8'
        optionsTextColor:
          - '#89b4fa'
        selectedLineBgColor:
          - '#313244'
        cherryPickedCommitBgColor:
          - '#45475a'
        cherryPickedCommitFgColor:
          - '#cba6f7'
        unstagedChangesColor:
          - '#f38ba8'
        defaultFgColor:
          - '#cdd6f4'
        searchingActiveBorderColor:
          - '#f9e2af'
      authorColors:
        '*': '#b4befe'
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
