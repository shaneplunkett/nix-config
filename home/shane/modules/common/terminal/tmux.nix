{
  pkgs,
  ...
}:
let
  colours = import ../theme/colours.nix;

  bg = "default";
  default_fg = "#${colours.text}";
  session_fg = "#${colours.green}";
  session_selection_fg = "#${colours.base}";
  session_selection_bg = "#${colours.mauve}";
  active_window_fg = "#${colours.mauve}";
  active_pane_border = "#${colours.lavender}";
in
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    escapeTime = 0;
    shell = "${pkgs.fish}/bin/fish";
    newSession = false;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = vim-tmux-navigator;
      }
      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind-zo-new-window 'ctrl-y'
          set -g @sessionx-auto-accept 'off'
          set -g @sessionx-bind 'o'
          set -g @sessionx-window-height '50%'
          set -g @sessionx-window-width '80%'
          set -g @sessionx-custom-paths-subdirectories 'false'
          set -g @sessionx-filter-current 'false'
          set -g @sessionx-preview-location 'top'
          set -g @sessionx-preview-size '50%'
          set -g @sessionx-filtered-sessions 'scratch'
          set -g @sessionx-ls-command 'eza --color=always --icons=always'
        '';
      }
      {
        plugin = yank;
      }
      {
        plugin = tmux-thumbs;
      }
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color 'cyan'
          set -g @floax-bind 'p'
          set -g @floax-change-path 'true'
        '';
      }
      {
        plugin = tmux-fzf;
      }
    ];

    extraConfig = ''
      unbind r
      unbind c
      unbind %
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      set -g default-terminal "screen-256color"
      set -g terminal-features ",xterm-256color:RGB"
      set -g allow-passthrough on
      set -ga terminal-overrides ',xterm-ghostty:Tc'

      # Mouse works as expected
      set-option -g mouse on

      # easy-to-remember split pane commands
      bind 'H' split-window -v -c "#{pane_current_path}"
      bind 'V' split-window -h -c "#{pane_current_path}"
      bind w new-window -c "#{pane_current_path}"


      set-option -g status-position top
      set -g pane-base-index 1
      set-option -g renumber-windows on



      # Theme
      set -g status-left-length 200   # default: 10
      set -g status-right-length 200  # default: 10
      set -g status-left "#[fg=${session_fg},bold,bg=${bg}] #S #[fg=${default_fg},nobold,bg=${bg}] | "
      set -g status-right " #{cpu -i 3}   #{mem} "
      set -g status-justify left
      set -g status-style "bg=${bg}"
      set -g window-status-format "#[fg=${default_fg},bg=default] #I:#W"
      set -g window-status-current-format "#[fg=${active_window_fg},bold,bg=default]  #[underscore]#I:#W"
      set -g window-status-last-style "fg=${default_fg},bg=default"
      set -g message-command-style "bg=default,fg=${default_fg}"
      set -g message-style "bg=default,fg=${default_fg}"
      set -g mode-style "bg=${session_selection_bg},fg=${session_selection_fg}"
      set -g pane-active-border-style "fg=${active_pane_border},bg=default"
      set -g pane-border-style "fg=brightblack,bg=default"

    '';
  };

}
