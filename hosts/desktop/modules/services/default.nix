{ ... }:
{

  imports = [

    ./greetd.nix
    ./noctalia-v5-session.nix

  ];

  services = {
    xserver.videoDrivers = [ "amdgpu" ];
    flatpak.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    tailscale.enable = true;

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
