# Shared helpers for the AI harness modules (cc, codex, mcp, linear, skills).
# Exposed to those modules as the `aiHelpers` module argument by ./default.nix.
{
  pkgs,
  lib,
  inputs,
}:
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

  # Hooks declared once for every harness; see ./hooks.
  inherit (import ./hooks { inherit pkgs lib; }) hooksFor;

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
