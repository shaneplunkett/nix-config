let
  shane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ";
in
{
  "restic-password.age".publicKeys = [ shane ];
  "vex-core.age".publicKeys = [ shane ];
  "vex-compaction.age".publicKeys = [ shane ];
  "vex-session-start.age".publicKeys = [ shane ];
  "vex-session-reload.age".publicKeys = [ shane ];
  "vex-discord-token.age".publicKeys = [ shane ];
}
