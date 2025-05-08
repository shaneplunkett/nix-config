{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;

    plugins = with pkgs; [
      tmuxPlugins.catppuccin
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.tmux-sessionx
      tmuxPlugins.yank
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.tmux-floax
      tmuxPlugins.tmux-fzf

    ];

    extraConfig = ''
      set -g default-terminal "screen-256color"
      set -as default-features ",xterm-256color:RGB"

      # Mouse works as expected
      set-option -g mouse on

      # easy-to-remember split pane commands
      bind 'h' split-window -v -c "#{pane_current_path}"
      bind 'v' split-window -h -c "#{pane_current_path}"
      bind w new-window -c "#{pane_current_path}"

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set-option -g status-position top
      set -g pane-base-index 1
      set-option -g renumber-windows on

        # Session Config
        set -g @continuum-restore 'on'
        set -g @resurrect-strategy-nvim 'session'

        # SessionX Config
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

        # Floax Config
        set -g @floax-width '80%'
        set -g @floax-height '80%'
        set -g @floax-border-color 'cyan'
        set -g @floax-bind 'p'
        set -g @floax-change-path 'true'

        # Catppuccin Config
        set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_number_position "right"
        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_default_text "#W"
        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#W"
        set -g @catppuccin_status_modules_right "directory"
        set -g @catppuccin_status_modules_left "session"
        set -g @catppuccin_status_left_separator " "
        set -g @catppuccin_status_right_separator " "
        set -g @catppuccin_status_right_separator_inverse "no"
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"
        set -g @catppuccin_directory_text "#{b:pane_current_path}"
        set -g @catppuccin_date_time_text "%H:%M"
    '';
  };

}
