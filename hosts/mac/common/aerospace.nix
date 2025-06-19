{ ... }:
{

  services.aerospace = {
    enable = true;
    settings = {
      after-startup-command = [
        "exec-and-forget borders active_color=0xffcba6f7 inactive_color=0xff585b70 width=5.0"
      ];
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

        # Workspace Config
        "alt-b" = "workspace B";
        "alt-t" = "workspace T";
        "alt-s" = "workspace S";
        "alt-p" = "workspace P";

        # Move Between Workspace
        "alt-shift-b" = "move-node-to-workspace B";
        "alt-shift-t" = "move-node-to-workspace T";
        "alt-shift-s" = "move-node-to-workspace S";
        "alt-shift-p" = "move-node-to-workspace P";
      };
      # Join Windows
      mode.service.binding = {
        "alt-shift-h" = [
          "join-with left"
          "mode main"
        ];
        "alt-shift-j" = [
          "join-with down"
          "mode main"
        ];
        "alt-shift-k" = [
          "join-with up"
          "mode main"
        ];
        "alt-shift-l" = [
          "join-with right"
          "mode main"
        ];
      };
    };
  };
}
