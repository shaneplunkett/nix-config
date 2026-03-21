{ pkgs, lib, compositor, ... }:
let
  colours = import ../../../home/shane/modules/common/theme/colours.nix;

  greeterBackground = builtins.toString ../assets/greeter-bg.jpg;

  # Minimal Hyprland config for the greeter session only
  greeterHyprlandConfig = pkgs.writeText "greetd-hyprland.conf" ''
    exec-once = regreet; hyprctl dispatch exit

    monitor = DP-2, 3840x2160@240, 0x0, 1.2
    monitor = HDMI-A-1, disable

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    env = GTK_USE_PORTAL,0
    env = GDK_DEBUG,no-portals
  '';
in
{
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.tailscale.enable = true;

  programs.regreet = {
    enable = true;

    cageArgs = [ "-s" ];  # not used — overridden by Hyprland below

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
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };

      widget.clock = {
        format = "%H:%M";
        resolution = "500ms";
      };
    };

    extraCss = ''
      /* ── catppuccin mocha — regreet ── */

      /* transparent window so wallpaper picture shows through */
      window {
        background-color: transparent;
      }

      /* all text defaults */
      label {
        color: #${colours.text};
        font-family: "Mononoki Nerd Font", monospace;
      }

      /* ── login card (frosted glass) ── */
      frame.background {
        background-color: alpha(#${colours.base}, 0.65);
        border-radius: 16px;
        border: 1px solid alpha(#${colours.lavender}, 0.08);
        box-shadow: 0 8px 32px alpha(black, 0.4);
        padding: 32px;
      }

      frame.background > grid {
        row-spacing: 12px;
      }

      /* ── greeting label ── */
      label#message_label {
        color: #${colours.text};
        font-size: 16px;
        margin-bottom: 12px;
      }

      /* ── clock ── */
      frame#clock_frame {
        background-color: transparent;
        border: none;
        box-shadow: none;
        padding: 12px 24px;
      }

      frame#clock_frame label {
        color: #${colours.lavender};
        font-size: 48px;
        font-weight: 300;
        letter-spacing: 2px;
      }

      /* ── input fields ── */
      entry {
        color: #${colours.text};
        background-color: #${colours.surface0};
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 10px 14px;
        font-family: "Mononoki Nerd Font", monospace;
        font-size: 14px;
        caret-color: #${colours.mauve};
        min-height: 20px;
      }

      entry:focus {
        border-color: #${colours.mauve};
        background-color: alpha(#${colours.surface1}, 0.9);
        box-shadow: 0 0 0 3px alpha(#${colours.mauve}, 0.1);
      }

      /* ── login button ── */
      button.suggested-action {
        color: #${colours.crust};
        background-color: #${colours.mauve};
        border: none;
        border-radius: 8px;
        padding: 10px 20px;
        font-family: "Mononoki Nerd Font", monospace;
        font-size: 14px;
        font-weight: 600;
        letter-spacing: 1px;
        min-height: 20px;
      }

      button.suggested-action:hover {
        background-color: #${colours.lavender};
      }

      button.suggested-action:active {
        background-color: #${colours.mauve};
      }

      /* ── cancel / toggle buttons ── */
      button#cancel_button,
      button.toggle {
        background-color: #${colours.surface0};
        color: #${colours.subtext0};
        border: none;
        border-radius: 8px;
        min-height: 20px;
      }

      button#cancel_button:hover,
      button.toggle:hover {
        background-color: #${colours.surface1};
        color: #${colours.text};
      }

      /* ── power buttons ── */
      button.destructive-action {
        background-color: transparent;
        color: #${colours.overlay1};
        border: none;
        border-radius: 8px;
        padding: 8px 12px;
        font-size: 12px;
      }

      button.destructive-action:hover {
        color: #${colours.maroon};
        background-color: alpha(#${colours.surface1}, 0.4);
      }

      /* ── session/user combo boxes ── */
      combobox {
        font-family: "Mononoki Nerd Font", monospace;
      }

      combobox box.linked button.combo {
        background-color: #${colours.surface0};
        color: #${colours.subtext0};
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 8px 12px;
        min-height: 20px;
      }

      combobox box.linked button.combo:hover {
        background-color: #${colours.surface1};
        color: #${colours.text};
      }

      /* combo popup menu */
      window.popup > contents {
        background-color: #${colours.surface0};
        border: 1px solid #${colours.surface1};
        border-radius: 8px;
      }

      /* ── error infobar ── */
      infobar {
        background-color: alpha(#${colours.red}, 0.15);
        border-radius: 8px;
      }

      infobar label {
        color: #${colours.red};
      }

      /* ── entry labels (User:, Session:, etc) ── */
      frame.background > grid > label {
        color: #${colours.subtext0};
        font-size: 13px;
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

  # Passwordless sudo for nixos-rebuild (allows Claude Code to switch)
  security.sudo.extraRules = [{
    users = [ "shane" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  # Use Hyprland as the greeter compositor — proper monitor config, centers correctly
  # This is independent of the user's session compositor (can be Hyprland, niri, etc.)
  services.greetd.settings.default_session = {
    command = lib.mkForce "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.hyprland} -c ${greeterHyprlandConfig}";
    user = "greeter";
  };

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };
}
