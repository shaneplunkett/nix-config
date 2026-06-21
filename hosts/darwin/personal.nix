{ ... }:

{
  imports = [
    ../../modules/common
    ../../modules/darwin
  ];

  # Keep the personal Mac awake — Hermes runs on it as an always-on gateway,
  # now managed manually outside Nix rather than via a launchd agent here.
  power.sleep = {
    computer = "never";
    display = "never";
    harddisk = "never";
  };

  system.stateVersion = 6;
}
