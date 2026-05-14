{
  pkgs,
  ...
}:
let
  jiraEnvLoader = ''
    --run '
    export ATLASSIAN_EMAIL="''${ATLASSIAN_EMAIL:-shane@autograb.com.au}"
    export ATLASSIAN_DOMAIN="''${ATLASSIAN_DOMAIN:-autograb.atlassian.net}"
    if [ -z "''${JIRA_API_TOKEN:-}" ]; then
      JIRA_API_TOKEN="$(${pkgs.rbw}/bin/rbw get atlassian-api-token 2>/dev/null)"
      export JIRA_API_TOKEN
    fi
    export JIRA_AUTH_TYPE="''${JIRA_AUTH_TYPE:-basic}"
    '
  '';

  confluenceEnvLoader = ''
    --run '
    export ATLASSIAN_EMAIL="''${ATLASSIAN_EMAIL:-shane@autograb.com.au}"
    export ATLASSIAN_DOMAIN="''${ATLASSIAN_DOMAIN:-autograb.atlassian.net}"
    if [ -z "''${CONFLUENCE_API_TOKEN:-}" ]; then
      CONFLUENCE_API_TOKEN="$(${pkgs.rbw}/bin/rbw get atlassian-api-token 2>/dev/null)"
      export CONFLUENCE_API_TOKEN
    fi
    export CONFLUENCE_DOMAIN="''${CONFLUENCE_DOMAIN:-$ATLASSIAN_DOMAIN}"
    export CONFLUENCE_EMAIL="''${CONFLUENCE_EMAIL:-$ATLASSIAN_EMAIL}"
    export CONFLUENCE_AUTH_TYPE="''${CONFLUENCE_AUTH_TYPE:-basic}"
    '
  '';

  jiraCliWrapped = pkgs.symlinkJoin {
    name = "jira-cli-wrapped-${pkgs.jira-cli-go.version}";
    paths = [ pkgs.jira-cli-go ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/jira
      makeWrapper ${pkgs.jira-cli-go}/bin/jira $out/bin/jira ${jiraEnvLoader}
    '';
    meta = pkgs.jira-cli-go.meta // {
      description = "jira-cli-go wrapped to auto-load Atlassian env from rbw";
    };
  };

  confluenceCliWrapped = pkgs.symlinkJoin {
    name = "confluence-cli-wrapped-${pkgs.confluence-cli.version}";
    paths = [ pkgs.confluence-cli ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in confluence confluence-cli; do
        if [ -e $out/bin/$bin ]; then
          rm $out/bin/$bin
          makeWrapper ${pkgs.confluence-cli}/bin/$bin $out/bin/$bin ${confluenceEnvLoader}
        fi
      done
    '';
    meta = pkgs.confluence-cli.meta // {
      description = "confluence-cli wrapped to auto-load Atlassian env from rbw";
    };
  };
in
{
  home.packages = [
    jiraCliWrapped
    confluenceCliWrapped
  ];

  home.file.".config/.jira/.config.yml".text = ''
    installation: cloud
    server: https://autograb.atlassian.net
    login: shane@autograb.com.au
    auth_type: basic
    project:
      key: AG
      type: classic
    epic:
      name: Epic Name
      link: Epic Link
    issue:
      fields:
        custom: []
  '';
}
