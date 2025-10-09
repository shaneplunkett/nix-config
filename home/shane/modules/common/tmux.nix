{
  pkgs,
  ...
}:
let
  # Nord theme colors
  bg = "default";
  default_fg = "#D8DEE9";
  session_fg = "#A3BE8C";
  session_selection_fg = "#3B4252";
  session_selection_bg = "#81A1C1";
  active_window_fg = "#88C0D0";
  active_pane_border = "#abb2bf";
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
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
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
          set -g @sessionx-ls-command 'lsd --color=always --icon=always'
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
