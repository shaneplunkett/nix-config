{ ... }:
{

  services.aerospace = {
    enable = true;
    settings = {
      default-root-container-layout = "tiles";
      automatically-unhide-macos-hidden-apps = true;
      gaps = {
        outer.left = 20;
        outer.right = 20;
        outer.top = 20;
        outer.bottom = 20;
        inner.horizontal = 20;
        inner.vertical = 20;

      };
      mode.main.binding = {
        "alt-h" = "focus left";
        "alt-j" = "focus down";
        "alt-k" = "focus up";
        "alt-l" = "focus right";

        "alt-shift-h" = "move left";
        "alt-shift-j" = "move down";
        "alt-shift-k" = "move up";
        "alt-shift-l" = "move down";

        "alt-minus" = "resize smart -50";
        "alt-equal" = "resize smart +50";
      };
    };
  };
}
