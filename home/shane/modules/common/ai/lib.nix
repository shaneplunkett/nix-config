# Shared helpers for the AI harness modules (cc, codex, mcp, linear, skills).
# Exposed to those modules as the `aiHelpers` module argument by ./default.nix.
{ pkgs, lib, inputs }:
{
  aiSkillsRoot = inputs.ai-skills.outPath;

  skillProfiles = inputs.ai-skills.lib.skillProfiles.${pkgs.stdenv.hostPlatform.system};

  # Ensure XDG_RUNTIME_DIR is set so rbw can reach its agent from non-login
  # contexts such as MCP servers and hooks.
  rbwRuntimeEnv = ''
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      runtime_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      if [ -d "$runtime_dir" ]; then
        export XDG_RUNTIME_DIR="$runtime_dir"
      fi
    fi
  '';

  # One guard script shared by every harness; the argument selects the
  # harness-specific payload handling inside git-commit-guard.sh.
  mkCommitGuard =
    harness:
    pkgs.writeShellApplication {
      name = "${harness}-git-commit-guard";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.git
        pkgs.gnugrep
        pkgs.jq
      ];
      text = ''exec ${pkgs.bash}/bin/bash ${./git-commit-guard.sh} ${harness} "$@"'';
    };

  # Install a skill profile as store symlinks under a harness config dir.
  mkSkillTree =
    {
      dir,
      skills,
      recursive ? false,
    }:
    lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${dir}/${name}" {
        inherit source recursive;
        force = true;
      }
    ) skills;

  # Concatenate markdown files into one prompt/context document.
  readMarkdownBundle = lib.concatMapStringsSep "\n\n" builtins.readFile;
}
