{ pkgs, ... }:
let
  colours = import ../../common/theme/colours.nix;

  rofiTheme = pkgs.writeText "rounded-catppuccin.rasi" ''
    /* ROUNDED THEME FOR ROFI - CATPPUCCIN MOCHA */

    * {
        font:   "Roboto 12";

        /* Catppuccin Mocha color palette */
        bg0:    #${colours.base}F2;
        bg1:    #${colours.mantle};
        bg2:    #${colours.surface2}80;
        bg3:    #${colours.mauve}F2;
        fg0:    #${colours.text};
        fg1:    #${colours.subtext1};
        fg2:    #${colours.text};
        fg3:    #${colours.surface2};

        background-color:   transparent;
        text-color:         @fg0;

        margin:     0px;
        padding:    0px;
        spacing:    0px;
    }

    window {
        location:       north;
        y-offset:       calc(50% - 176px);
        width:          480;
        border-radius:  24px;

        background-color:   @bg0;
    }

    mainbox {
        padding:    12px;
    }

    inputbar {
        background-color:   @bg1;
        border-color:       @bg3;

        border:         2px;
        border-radius:  16px;

        padding:    8px 16px;
        spacing:    8px;
        children:   [ prompt, entry ];
    }

    prompt {
        text-color: @fg2;
    }

    entry {
        placeholder:        "Search";
        placeholder-color:  @fg3;
    }

    message {
        margin:             12px 0 0;
        border-radius:      16px;
        border-color:       @bg2;
        background-color:   @bg2;
    }

    textbox {
        padding:    8px 24px;
    }

    listview {
        background-color:   transparent;

        margin:     12px 0 0;
        lines:      8;
        columns:    1;

        fixed-height: false;
    }

    element {
        padding:        8px 16px;
        spacing:        8px;
        border-radius:  16px;
    }

    element normal active {
        text-color: @bg3;
    }

    element alternate active {
        text-color: @bg3;
    }

    element selected normal, element selected active {
        background-color:   @bg3;
    }

    element selected {
        text-color: @bg1;
    }

    element-icon {
        size:           1em;
        vertical-align: 0.5;
    }

    element-text {
        text-color: inherit;
    }
  '';
in
{
  programs.rofi = {
    enable = true;
    theme = "${rofiTheme}";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
    };
  };
}
