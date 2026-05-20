{
  pkgs,
  lib,
  ...
}:
let
  colours = import ../../../../home/shane/modules/common/theme/colours.nix;

  greeterBackground = toString ../assets/greeter-bg.jpg;
  greeterCmd = pkgs.writeShellApplication {
    name = "regreet-wrapper";
    runtimeInputs = [
      pkgs.wlr-randr
      pkgs.regreet
    ];
    text = ''
      wlr-randr --output HDMI-A-1 --off &
      sleep 0.5
      exec regreet
    '';
  };
in
{
  programs.regreet = {
    enable = true;
    cageArgs = [ "-s" ];

    settings = {
      background = {
        path = greeterBackground;
        fit = "Cover";
      };

      appearance = {
        greeting_msg = "welcome back, shane";
      };

      GTK = {
        application_prefer_dark_theme = true;
      };

      commands = {
        reboot = [
          "systemctl"
          "reboot"
        ];
        poweroff = [
          "systemctl"
          "poweroff"
        ];
      };

      widget.clock = {
        format = "%H:%M";
        resolution = "500ms";
      };
    };

    extraCss =
      let
        paletteVars = [
          "base"
          "mantle"
          "crust"
          "surface0"
          "surface1"
          "surface2"
          "overlay0"
          "overlay1"
          "text"
          "subtext0"
          "lavender"
          "mauve"
          "maroon"
          "red"
        ];
        defineColors = lib.concatMapStringsSep "\n" (v: "@define-color ${v} #${colours.${v}};") paletteVars;
      in
      defineColors + "\n\n" + builtins.readFile ./greetd-theme.css;

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve-cursors";
    };

    font = {
      package = pkgs.nerd-fonts.mononoki;
      name = "Mononoki Nerd Font";
      size = 14;
    };
  };
  services.greetd.settings.default_session.command =
    lib.mkForce "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${greeterCmd}/bin/regreet-wrapper";

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };
}
