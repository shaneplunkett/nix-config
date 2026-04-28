{ pkgs, ... }:
{
  lazycommit = pkgs.callPackage ./lazycommit/lazycommit.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };

  confluence-cli = pkgs.callPackage ./confluence-cli/confluence-cli.nix { };

  agent-slack = pkgs.callPackage ./agent-slack/agent-slack.nix { };

  todoist-cli = pkgs.callPackage ./todoist-cli/todoist-cli.nix { };

  langsmith-cli = pkgs.callPackage ./langsmith-cli/langsmith-cli.nix { };
}
