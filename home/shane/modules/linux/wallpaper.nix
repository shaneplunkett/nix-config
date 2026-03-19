{ pkgs, config, ... }:
let
  wallpaperDir = "${config.home.homeDirectory}/wallpapers";

  wallpaper-switch = pkgs.writeShellApplication {
    name = "wallpaper-switch";
    runtimeInputs = with pkgs; [ coreutils findutils hyprland ];
    text = ''
      WALLPAPER_DIR="${wallpaperDir}"
      STATE_FILE="$HOME/.cache/current-wallpaper"

      # Find all image files
      mapfile -t images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf)

      if [[ ''${#images[@]} -eq 0 ]]; then
        echo "No wallpapers found in $WALLPAPER_DIR"
        exit 1
      fi

      # Pick a random one
      selected="''${images[0]}"

      # Apply to both monitors
      hyprctl hyprpaper wallpaper "DP-2,$selected"
      hyprctl hyprpaper wallpaper "HDMI-A-1,$selected"

      # Save state
      mkdir -p "$(dirname "$STATE_FILE")"
      echo "$selected" > "$STATE_FILE"
    '';
  };
in
{
  home.packages = [ wallpaper-switch ];

  # HyprPanel custom module definition
  xdg.configFile."hyprpanel/modules.json".text = builtins.toJSON {
    "custom/wallpaper" = {
      icon = "󰸉";
      label = "";
      tooltip = "Random wallpaper";
      execute = "";
      interval = 0;
      actions = {
        onLeftClick = "wallpaper-switch";
      };
    };
  };

  # Style the custom module via styleModule mixin with hardcoded values
  xdg.configFile."hyprpanel/modules.scss".text = ''
    @include styleModule(
        'cmodule-wallpaper',
        (
            'icon-color': #cba6f7,
            'label-background': #242438,
            'border-enabled': false,
            'icon-size': 1.2em,
        )
    );
    .module-label.cmodule-wallpaper {
        min-width: 0;
        padding: 0;
        margin: 0;
    }
  '';

}
