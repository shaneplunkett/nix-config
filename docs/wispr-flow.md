# Wispr Flow on the desktop

The desktop installs the unofficial Linux port from
[wispr-flow-linux](https://github.com/wispr-flow-linux/wispr-flow-linux).
It is not supported by Wispr. Sign-in and cloud dictation still use Wispr's
service and terms. Nothing starts automatically with the desktop.

## Packaging

`pkgs/wispr-flow/default.nix` pins the Linux AppImage by release tag and SHA-256.
The version combines the port and app versions, matching the upstream tag.
Update with `nix-update --flake wispr-flow`, then build and test before switching.

We deliberately do not consume upstream's flake. At the inspected revision it
requires a manually supplied Windows installer, has a `lib.fakeHash` helper
source, and explicitly leaves the Windows SQLite native modules unreplaced.
The released AppImage includes the built Linux modules instead.

Nix extracts the AppImage and supplies its runtime libraries and clipboard
tools. The launcher uses upstream's `nix` argument mode rather than `appimage`
mode so it does not disable Chromium's sandbox for a FUSE limitation that does
not apply to this installation. This does not force the app's own renderers to
use sandboxing; upstream still launches some renderer processes unsandboxed.

## Permissions and first use

`hosts/desktop/modules/wispr-flow.nix` installs the app and enables uinput for
text injection. Sunshine already grants Shane access to uinput. Push-to-talk
needs keyboard event access, so a udev rule grants it to the active local
session. It does not add Shane to the broad `input` group or grant access to
every event device. Other applications running as that session user can also
read keyboard events; this is not an app-specific permission.

After switching, launch **Wispr Flow** from the app launcher, or run
`wispr-flow`. Sign in and complete its onboarding, then test a short dictation
in a disposable text field. Home Manager registers the `wispr-flow://` browser
sign-in callback against the installed desktop entry.
Run `wispr-flow --doctor` for dependency and device
checks. If keyboard permissions have not refreshed, reconnect the keyboard or
log out and back in. Do not use `--install-udev-rules`; NixOS owns those rules.

Upstream's diagnostic may warn about not being in the `input` group even when
the actual device permissions work. Check the device-access results rather
than adding the group just to silence that warning.

It also reports a `chrome-sandbox` failure because it assumes a setuid-root
Debian/RPM installation. Do not run its suggested `chown`/`chmod` against the
Nix store. The app launches here without that setuid helper and without a
global `--no-sandbox` flag. Its desktop-entry check is also hard-coded to a
Debian path, rather than NixOS's system profile.

## Trial verification, 14 September 2026

- `statix check .`, `deadnix` on the changed Nix files, the desktop host build,
  `nix flake check`, and `nh os switch . -H desktop` passed.
- The app opened its sign-in screen on Hyprland. SQLite migrations completed;
  both SQLite native modules are Linux ELF binaries. Microphone enumeration
  found the desktop's audio inputs. The URL handler resolves to our desktop file.
- The doctor launched helper 0.1.2 and Electron 42.3.0 and passed clipboard and
  uinput checks. Keyboard access still needs a device reconnect or a privileged
  udev refresh in the existing session. Its setuid-sandbox check also fails as
  described above. Full sign-in, push-to-talk and cloud dictation are untested.

Config lives in `~/.config/Wispr Flow/`; launcher logs are in
`~/.cache/wispr-flow/launcher.log`. Logs and dictation history can contain private
content. Review before sharing.

## Removing the trial

Remove the `./wispr-flow.nix` desktop import and rebuild to remove the app and
keyboard rule. Existing user data is left untouched. The package can remain
available in the flake without being installed. Re-login/reconnect the keyboard
if an existing device ACL has not yet refreshed.
