{ pkgs, compositor, ... }:
let
  colours = import ../../../home/shane/modules/common/theme/colours.nix;

  greeterBackground = builtins.toString ../assets/greeter-bg.jpg;
in
{
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.tailscale.enable = true;

  programs.regreet = {
    enable = true;

    settings = {
      background = {
        path = greeterBackground;
        fit = "Cover";
      };

      appearance = {
        greeting_msg = "welcome back";
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
      /* ── catppuccin mocha — regreet theme ── */

      /* main window — transparent so wallpaper shows */
      window {
        background-color: transparent;
      }

      /* ── frosted glass card ── */
      box.container {
        background-color: alpha(#${colours.base}, 0.65);
        border-radius: 16px;
        border: 1px solid alpha(#${colours.lavender}, 0.08);
        box-shadow: 0 8px 32px alpha(black, 0.4);
        padding: 36px 32px;
      }

      /* ── text ── */
      label {
        color: #${colours.text};
        font-family: "Mononoki Nerd Font", monospace;
      }

      label.greeting {
        color: #${colours.text};
        font-size: 18px;
        font-weight: 400;
        letter-spacing: 0.5px;
      }

      label.clock {
        color: #${colours.lavender};
        font-size: 64px;
        font-weight: 300;
        letter-spacing: 2px;
      }

      label.date {
        color: #${colours.subtext0};
        font-size: 14px;
        letter-spacing: 1.5px;
        text-transform: uppercase;
      }

      /* ── input fields ── */
      entry {
        color: #${colours.text};
        background-color: #${colours.surface0};
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 12px 14px;
        font-family: "Mononoki Nerd Font", monospace;
        font-size: 14px;
        caret-color: #${colours.mauve};
        transition: all 200ms ease;
      }

      entry:focus {
        border-color: #${colours.mauve};
        background-color: alpha(#${colours.surface1}, 0.9);
        box-shadow: 0 0 0 3px alpha(#${colours.mauve}, 0.1);
      }

      entry placeholder {
        color: #${colours.overlay0};
      }

      /* ── buttons ── */
      button {
        color: #${colours.crust};
        background-color: #${colours.mauve};
        border: none;
        border-radius: 8px;
        padding: 12px 20px;
        font-family: "Mononoki Nerd Font", monospace;
        font-size: 14px;
        font-weight: 600;
        letter-spacing: 1px;
        transition: all 200ms ease;
      }

      button:hover {
        background-color: #${colours.lavender};
      }

      button:active {
        background-color: #${colours.mauve};
      }

      /* power/system buttons */
      button.destructive-action {
        background-color: transparent;
        color: #${colours.overlay1};
        border: none;
        font-size: 12px;
      }

      button.destructive-action:hover {
        color: #${colours.maroon};
        background-color: alpha(#${colours.surface1}, 0.4);
      }

      button.flat {
        background-color: transparent;
        color: #${colours.overlay1};
        border: none;
      }

      button.flat:hover {
        color: #${colours.text};
        background-color: alpha(#${colours.surface1}, 0.4);
      }

      /* ── combo boxes (session selector) ── */
      combobox {
        color: #${colours.subtext0};
        background-color: transparent;
        border: 1px solid #${colours.surface1};
        border-radius: 6px;
        font-size: 12px;
      }

      combobox:hover {
        border-color: #${colours.overlay0};
        color: #${colours.text};
      }

      dropdown {
        background-color: #${colours.surface0};
        border-radius: 8px;
        border: 1px solid #${colours.surface1};
      }

      dropdown > popover > contents {
        background-color: #${colours.surface0};
      }

      /* ── scrollbar ── */
      scrollbar {
        background-color: transparent;
      }

      scrollbar slider {
        background-color: #${colours.surface2};
        border-radius: 4px;
        min-width: 6px;
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

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
    };
    unitConfig = {
      After = [ "multi-user.target" ];
    };
  };
}
