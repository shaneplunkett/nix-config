{
  pkgs,
  lib,
  compositor,
  ...
}:
let
  colours = import ../../../home/shane/modules/common/theme/colours.nix;

  greeterBackground = toString ../assets/greeter-bg.jpg;

  # Wrapper script: disable HDMI-A-1 inside cage, then run regreet
  greeterCmd = pkgs.writeShellScript "regreet-wrapper" ''
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off &
    sleep 0.5
    ${lib.getExe pkgs.regreet}
  '';
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

    extraCss = ''
      @define-color base #${colours.base};
      @define-color mantle #${colours.mantle};
      @define-color crust #${colours.crust};
      @define-color surface0 #${colours.surface0};
      @define-color surface1 #${colours.surface1};
      @define-color surface2 #${colours.surface2};
      @define-color overlay0 #${colours.overlay0};
      @define-color overlay1 #${colours.overlay1};
      @define-color text #${colours.text};
      @define-color subtext0 #${colours.subtext0};
      @define-color lavender #${colours.lavender};
      @define-color mauve #${colours.mauve};
      @define-color maroon #${colours.maroon};
      @define-color red #${colours.red};

      window {
        background-color: transparent;
      }

      headerbar, .titlebar, windowhandle {
        min-height: 0;
        background-color: transparent;
        background-image: none;
        box-shadow: none;
        border: none;
      }

      label {
        color: @text;
        font-family: "Mononoki Nerd Font", monospace;
      }

      #message_label {
        font-size: 16px;
        margin-bottom: 8px;
      }

      #clock_frame {
        background-color: transparent;
        background-image: none;
        border: none;
        box-shadow: none;
      }

      #clock_frame label {
        color: @lavender;
        font-size: 48px;
        font-weight: 300;
        letter-spacing: 2px;
      }

      entry {
        background-color: @surface0;
        background-image: none;
        color: @text;
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 10px 14px;
        font-family: "Mononoki Nerd Font", monospace;
        font-size: 14px;
        caret-color: @mauve;
        min-height: 20px;
        transition: border-color 200ms ease-in-out;
      }

      entry:focus {
        border-color: @mauve;
        box-shadow: 0 0 0 2px alpha(@mauve, 0.15);
      }

      button {
        background-image: none;
        border-radius: 8px;
        font-family: "Mononoki Nerd Font", monospace;
        min-height: 20px;
        transition: background-color 200ms ease-in-out;
      }

      button.suggested-action {
        background-color: @mauve;
        color: @crust;
        border: none;
        padding: 10px 20px;
        font-size: 14px;
        font-weight: 600;
        letter-spacing: 1px;
      }

      button.suggested-action:hover {
        background-color: @lavender;
      }

      button.destructive-action {
        background-color: transparent;
        background-image: none;
        color: @overlay1;
        border: none;
        padding: 8px 12px;
        font-size: 12px;
      }

      button.destructive-action:hover {
        color: @maroon;
        background-color: alpha(@surface1, 0.4);
      }

      combobox button {
        background-color: @surface0;
        background-image: none;
        color: @subtext0;
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 8px 12px;
        min-height: 20px;
      }

      combobox button:hover {
        background-color: @surface1;
        color: @text;
      }

      window.popup > contents {
        background-color: @surface0;
        border: 1px solid @surface1;
        border-radius: 8px;
      }

      #error_info {
        background-color: alpha(@red, 0.15);
        border-radius: 8px;
      }

      #error_label {
        color: @red;
      }
    '';

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

  # Override cage command to use wrapper that disables HDMI-A-1
  services.greetd.settings.default_session.command =
    lib.mkForce "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${greeterCmd}";

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };
}
