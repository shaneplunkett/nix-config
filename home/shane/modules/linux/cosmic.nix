# Catppuccin for COSMIC apps (the file picker comes from xdg-desktop-portal-cosmic).
# COSMIC apps read a fully built theme that cosmic-settings-daemon normally
# generates from builder settings. Outside COSMIC nothing does, so build it
# here with cosmic-ctl from Catppuccin's Mocha Mauve theme.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  rev = "95e81098042dd2102f0b258f6990f886c5759692";
  catppuccinTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/cosmic-desktop/${rev}/themes/cosmic-settings/catppuccin-mocha-mauve%2Bround.ron";
    hash = "sha256-/XUIANPnrO/nRHXMfjIWb+sNmSjNGIaLU4EJ/HP7IMI=";
  };

  # The theme file is one RON struct; COSMIC's config keeps each top-level
  # field as its own file.
  splitBuilder = pkgs.writeText "split-cosmic-theme.py" ''
    import pathlib, re, sys

    lines = pathlib.Path(sys.argv[1]).read_text().splitlines()[1:]
    fields, current = {}, None
    for line in lines:
        match = re.match(r"^    (\w+): ?(.*)$", line)
        if match:
            current = match.group(1)
            fields[current] = [match.group(2)]
        elif current and line.strip() != ")":
            fields[current].append(line)
    for name, value in fields.items():
        (pathlib.Path(sys.argv[2]) / name).write_text("\n".join(value).rstrip().rstrip(","))
  '';

  theme =
    pkgs.runCommand "cosmic-catppuccin-mocha-mauve"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.cosmic-ext-ctl
        ];
      }
      ''
        export HOME=$TMPDIR XDG_CONFIG_HOME=$TMPDIR/config
        builder=$XDG_CONFIG_HOME/cosmic/com.system76.CosmicTheme.Dark.Builder/v1
        mkdir -p "$builder"
        python3 ${splitBuilder} ${catppuccinTheme} "$builder"
        cosmic-ctl build-theme
        cp -r $XDG_CONFIG_HOME/cosmic/com.system76.CosmicTheme.Dark $out
      '';

  # COSMIC's font setting: a family plus enum weight, stretch and style.
  font = family: "(family: \"${family}\", weight: Normal, stretch: Normal, style: Normal)";
in
{
  xdg.configFile = {
    # cosmic-ctl (last released before COSMIC 1.9) builds the v1 theme; COSMIC
    # now reads v2, which keeps the same colour fields and adds a few more.
    "cosmic/com.system76.CosmicTheme.Dark/v2".source = "${theme}/v1";
    "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".text = "true";

    # Same icons and fonts as GTK and Qt (theme.nix).
    "cosmic/com.system76.CosmicTk/v1/icon_theme".text = "\"${config.gtk.iconTheme.name}\"";
    "cosmic/com.system76.CosmicTk/v1/interface_font".text = font config.gtk.font.name;
    "cosmic/com.system76.CosmicTk/v1/monospace_font".text = font (
      lib.head config.fonts.fontconfig.defaultFonts.monospace
    );
  };
}
