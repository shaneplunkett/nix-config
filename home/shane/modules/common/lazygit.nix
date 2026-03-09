{ ... }:
{
  xdg.configFile."lazygit/config.yml".text = ''
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
