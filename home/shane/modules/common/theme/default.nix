{ ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    # nixvim handles its own catppuccin plugin
    nvim.enable = false;

    # rofi uses a custom rounded theme — colours handled via central palette
    rofi.enable = false;

    # Qt uses GTK platform theme, not kvantum
    kvantum.enable = false;
  };
}
