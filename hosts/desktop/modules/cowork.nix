# Claude Desktop's Cowork feature runs its sandbox in a qemu microVM. The app
# resolves qemu-system-x86_64 from PATH, probes hardcoded Debian firmware
# paths under /usr/share/OVMF, and wants a system virtiofsd at
# /usr/libexec/virtiofsd (its bundled copy is only used on Ubuntu 22). All
# three must be provided at the system level — the claude-desktop package
# can't supply them.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.qemu_kvm ];

  systemd.tmpfiles.rules = [
    "L+ /usr/share/OVMF - - - - ${pkgs.OVMF.fd}/FV"
    "L+ /usr/libexec/virtiofsd - - - - ${pkgs.virtiofsd}/bin/virtiofsd"
  ];
}
