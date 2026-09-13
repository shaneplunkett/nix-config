{
  lib,
  pkgs,
  ...
}:
let
  rbw = lib.getExe pkgs.rbw;
in
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "shanemplunkett@icloud.com";
      lock_timeout = 604800;
      pinentry = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
    };
  };

  # Unlock once per desktop session. This used to happen accidentally when the
  # interactive shell fetched an Aikido token; keep it explicit now that the
  # work-only tooling is gone.
  programs.fish.loginShellInit = ''
    if test "$TERM_PROGRAM" = ghostty; and not ${rbw} unlocked >/dev/null 2>&1
      ${rbw} unlock
    end
  '';
}
