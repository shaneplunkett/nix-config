{
  pkgs,
  ...
}:
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "shanemplunkett@icloud.com";
      lock_timeout = 604800;
      pinentry =
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
    };
  };
}
