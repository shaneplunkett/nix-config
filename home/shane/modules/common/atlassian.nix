{
  config,
  pkgs,
  ...
}:
let
  jiraTokenPath = config.age.secrets.atlassian-api-token.path;
  confluenceTokenPath = config.age.secrets.atlassian-confluence-token.path;

  jiraEnvLoader = ''
    --run '
    if [ -r "${jiraTokenPath}" ]; then
      export ATLASSIAN_EMAIL="''${ATLASSIAN_EMAIL:-shane@autograb.com.au}"
      export ATLASSIAN_DOMAIN="''${ATLASSIAN_DOMAIN:-autograb.atlassian.net}"
      export JIRA_API_TOKEN="''${JIRA_API_TOKEN:-$(<"${jiraTokenPath}")}"
      export JIRA_AUTH_TYPE="''${JIRA_AUTH_TYPE:-basic}"
    fi
    '
  '';

  confluenceEnvLoader = ''
    --run '
    if [ -r "${confluenceTokenPath}" ]; then
      export ATLASSIAN_EMAIL="''${ATLASSIAN_EMAIL:-shane@autograb.com.au}"
      export ATLASSIAN_DOMAIN="''${ATLASSIAN_DOMAIN:-autograb.atlassian.net}"
      export CONFLUENCE_API_TOKEN="''${CONFLUENCE_API_TOKEN:-$(<"${confluenceTokenPath}")}"
      export CONFLUENCE_DOMAIN="''${CONFLUENCE_DOMAIN:-$ATLASSIAN_DOMAIN}"
      export CONFLUENCE_EMAIL="''${CONFLUENCE_EMAIL:-$ATLASSIAN_EMAIL}"
      export CONFLUENCE_AUTH_TYPE="''${CONFLUENCE_AUTH_TYPE:-basic}"
    fi
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
      description = "jira-cli-go wrapped to auto-load Atlassian env from agenix";
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
      description = "confluence-cli wrapped to auto-load Atlassian env from agenix";
    };
  };
in
{
  home.packages = [
    jiraCliWrapped
    confluenceCliWrapped
  ];

  # jira-cli-go config — declarative so `jira init` is never needed.
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
