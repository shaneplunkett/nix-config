{ config, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--hostname=hetzvps"
    ];
  };

  age.secrets.tailscale-authkey = {
    file = ../../../secrets/tailscale-authkey.age;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    extraConfig = ''
      Match User upload
        ForceCommand internal-sftp
        ChrootDirectory /home/upload
        PasswordAuthentication yes
        AllowTcpForwarding no
        X11Forwarding no
    '';
  };

  # Allow PAM password auth for sshd (needed for SFTP upload user;
  # sshd Match block restricts which users can actually use it)
  security.pam.services.sshd.unixAuth = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.shane = {
    isNormalUser = true;
    description = "Shane Plunkett";
    extraGroups = [
      "docker"
      "wheel"
    ];
    openssh.authorizedKeys.keyFiles = [ ../../../authorized-keys ];
  };

  users.users.upload = {
    isNormalUser = true;
    shell = "/bin/sh"; # PAM rejects nologin; ForceCommand internal-sftp prevents shell access
    home = "/home/upload";
    hashedPassword = "$6$VFRZaNQTiTcWSyiz$9Tcpv81djDZ4iVIQAV9oXKOtg19j7s21HSPp7c77tXkbYdbjU0s1IGK47DpumnEZDv1AluJ0XDrX9s.whfKDk.";
  };

  # Set upload user password and chroot directory structure
  system.activationScripts.sftpUpload = ''
    mkdir -p /home/upload/uploads
    chown root:root /home/upload
    chmod 755 /home/upload
    chown upload:users /home/upload/uploads
    chmod 755 /home/upload/uploads
  '';
}
