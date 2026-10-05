{ pkgs, ... }:
{

  imports = [

    ./amdgpu-dump-collector.nix
    ./noctalia-greeter.nix

  ];

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    flatpak.enable = true;
    tailscale.enable = true;
    # COSMIC Files mounts drives and network shares through GIO. The module
    # defaults to GNOME's gvfs (online accounts and friends); the plain build
    # is enough.
    gvfs = {
      enable = true;
      package = pkgs.gvfs;
    };
    udisks2.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  users.users.shane.openssh.authorizedKeys.keyFiles = [ ../../../../authorized-keys ];

}
