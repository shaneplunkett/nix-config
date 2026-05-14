{
  pkgs,
  ...
}:
let
  email = "shanemplunkett@icloud.com";
  rbw = "${pkgs.rbw}/bin/rbw";
in
{
  home.packages = [ pkgs.himalaya ];

  home.file.".config/himalaya/config.toml".text = ''
    [accounts.icloud]
    default = true
    email = "${email}"
    display-name = "Shane Plunkett"

    [accounts.icloud.folder.aliases]
    inbox = "INBOX"
    sent = "Sent Messages"
    drafts = "Drafts"
    trash = "Deleted Messages"
    junk = "Junk"

    [accounts.icloud.backend]
    type = "imap"
    host = "imap.mail.me.com"
    port = 993
    login = "${email}"

    [accounts.icloud.backend.encryption]
    type = "tls"

    [accounts.icloud.backend.auth]
    type = "password"
    cmd = "${rbw} get icloud-app-password"

    [accounts.icloud.message.send.backend]
    type = "smtp"
    host = "smtp.mail.me.com"
    port = 587
    login = "${email}"

    [accounts.icloud.message.send.backend.encryption]
    type = "start-tls"

    [accounts.icloud.message.send.backend.auth]
    type = "password"
    cmd = "${rbw} get icloud-app-password"
  '';
}
