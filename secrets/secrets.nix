let
  shane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfq31bP+xQwlO/joZeGU6LaLYZXV2ql7TLSv5ToVUtJ";
  #users = [ shane ];

  #systems = [ ];
in
{
  "context7.age".publicKeys = shane;
}
