{ ... }:

{
  imports = [
    ../../../modules/common
    ../../../modules/darwin/base
    ../../../modules/darwin/server
  ];

  # mini-server has to come back by itself: power on after an outage and log
  # straight in, so the login agents (vex-code) start without anyone at the
  # console. Auto-login needs FileVault off and the password stored once via
  # System Settings → Users & Groups, which writes /etc/kcpassword.
  power = {
    sleep.computer = "never";
    restartAfterPowerFailure = true;
  };

  system.defaults.loginwindow.autoLoginUser = "shane";

  system.stateVersion = 6;
}
