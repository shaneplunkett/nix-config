let
  shane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ";
  hetzvps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZsq1NuUb93XrV2+aX6ztiSOpvh2Ym/u8ssrxY44p+h";
in
{
  "tailscale-authkey.age".publicKeys = [
    shane
    hetzvps
  ];
  "restic-password.age".publicKeys = [ shane ];
  "vex-core.age".publicKeys = [ shane ];
  "vex-compaction.age".publicKeys = [ shane ];
  "vex-session-start.age".publicKeys = [ shane ];
  "vex-session-reload.age".publicKeys = [ shane ];
  "vex-discord-token.age".publicKeys = [ shane ];
}
