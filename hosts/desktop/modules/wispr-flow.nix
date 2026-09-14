{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.wispr-flow ];

  # Browser sign-in returns to the app through wispr-flow:// links.
  home-manager.users.shane.xdg.mimeApps.defaultApplications."x-scheme-handler/wispr-flow" = [
    "ai.wisprflow.WisprFlow.desktop"
  ];

  hardware.uinput.enable = true;

  # The helper reads evdev keyboards for push-to-talk. Limit the new grant to
  # keyboards in the active local session, not permanent input-group membership
  # or every input device. This also lets other apps in that session read keys.
  # Must run before 73-seat-late.rules applies logind's ACL. extraRules is too
  # late (99-local.rules), so install a named rule through udev.packages.
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-wispr-flow-keyboard.rules" ''
      SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_KEYBOARD}=="1", TAG+="uaccess"
    '')
  ];
}
