_:
{
  # NixOS-only flag; packages list lives in modules/common/fonts.nix
  # (shared with darwin which doesn't expose enableDefaultPackages).
  fonts.enableDefaultPackages = true;
}
