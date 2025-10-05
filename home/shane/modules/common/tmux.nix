{ pkgs
, ...
}:
let
  omerxx-catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2025-05-08";
    src = pkgs.fetchFromGitHub {
      owner = "Omerxx";
      repo = "catppuccin-tmux";
      rev = "e30336b79986e87b1f99e6bd9ec83cffd1da2017";
      sha256 = "sha256-Ig6+pB8us6YSMHwSRU3sLr9sK+L7kbx2kgxzgmpR920=";
    };
  };
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

    plugins = [
      omerxx-catppuccin
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.continuum
      pkgs.tmuxPlugins.tmux-sessionx
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.tmux-thumbs
      pkgs.tmuxPlugins.tmux-floax
      pkgs.tmuxPlugins.tmux-fzf
    ];

    extraConfig = ''
      unbind r
      unbind c
      unbind %
      bind r source-file ~/.config/tmux/tmux.conf

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
