{ pkgs, ... }:
let
  # Python packages live as inputs to the CLI wrapper; not exposed at the top
  # level since they have no useful standalone CLI.
  meetscribe-record-py = pkgs.python3Packages.callPackage ./meetscribe-record/meetscribe-record.nix { };
  meetscribe-py = pkgs.python3Packages.callPackage ./meetscribe/meetscribe.nix {
    meetscribe-record = meetscribe-record-py;
  };
in
{
  lazycommit = pkgs.callPackage ./lazycommit/lazycommit.nix { };

  youtui = pkgs.callPackage ./youtui/youtui.nix { };

  confluence-cli = pkgs.callPackage ./confluence-cli/confluence-cli.nix { };

  agent-slack = pkgs.callPackage ./agent-slack/agent-slack.nix { };

  todoist-cli = pkgs.callPackage ./todoist-cli/todoist-cli.nix { };

  langsmith-cli = pkgs.callPackage ./langsmith-cli/langsmith-cli.nix { };

  browserbase-cli = pkgs.callPackage ./browserbase-cli/browserbase-cli.nix { };

  meetscribe = pkgs.callPackage ./meetscribe/meetscribe-cli.nix {
    inherit (pkgs) ffmpeg pulseaudio symlinkJoin makeWrapper;
    pythonEnv = pkgs.python3.withPackages (_: [
      meetscribe-record-py
      meetscribe-py
    ]);
  };
}
