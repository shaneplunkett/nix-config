{ ... }:
{
  # Gemini system-prompt is the last file-shaped secret in agenix.
  # All credential strings live in rbw (Bitwarden) and arrive at runtime
  # via the CLI wrappers in vex-tooling. See CLAUDE.md "Secrets Management".
  age.secrets.gemini.file = ../../../../secrets/gemini.age;
}
