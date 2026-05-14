{ pkgs, ... }:
{
  # Aikido Security IDE-plugin key (consumed by the @aikidosec/mcp server
  # spawned by Claude Code's aikido plugin). The plugin's .mcp.json substitutes
  # AIKIDO_API_KEY into the server env, so we just need the var present in
  # the shell that launches Claude Code.
  programs.fish.interactiveShellInit = ''
    set -l aikido_key (${pkgs.rbw}/bin/rbw get aikido-token 2>/dev/null)
    if test -n "$aikido_key"
      set -gx AIKIDO_API_KEY "$aikido_key"
    end
  '';
}
