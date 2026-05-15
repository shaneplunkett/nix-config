{ config, ... }:
{
  # Yet another Nix CLI helper — wraps `nixos-rebuild` / `home-manager switch`
  # with prettier output, automatic flake-path resolution, and an opt-in diff
  # of changed store paths after each switch.
  #
  # nrs / nrs-iter fish functions now call `nh os switch` (or `nh darwin switch`
  # on macOS) under the hood — see modules/common/terminal/fish.nix.
  #
  # Auto-GC NOT enabled here — system-level `nix.gc.automatic` already runs
  # (see modules/{nixos,darwin}/maintenance.nix). The nh module warns if both
  # are enabled.
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nix-config";
  };
}
