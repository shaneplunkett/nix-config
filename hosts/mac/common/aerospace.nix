{ ... }:
{

  services.aerospace = {
    enable = true;
    settings = {
      after-startup-command = [
        "exec-and-forget /run/current-system/sw/bin/borders active_color=0xffcba6f7 inactive_color=0xff45475a width=10.0"
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
      workspace-to-monitor-force-assignment = {
        "1" = "main";
        "2" = "secondary";
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
        "alt-1" = "workspace 1";
        "alt-2" = "workspace 2";
        "alt-a" = "workspace A";
        "alt-b" = "workspace B";
        "alt-e" = "workspace E";
        "alt-f" = "workspace F";
        "alt-t" = "workspace T";
        "alt-s" = "workspace S";
        "alt-m" = "workspace M";
        "alt-o" = "workspace O";
        "alt-p" = "workspace P";

        # Move Between Workspace
        "alt-shift-1" = "move-node-to-workspace 1";
        "alt-shift-2" = "move-node-to-workspace 2";
        "alt-shift-a" = "move-node-to-workspace A";
        "alt-shift-b" = "move-node-to-workspace B";
        "alt-shift-e" = "move-node-to-workspace E";
        "alt-shift-f" = "move-node-to-workspace F";
        "alt-shift-t" = "move-node-to-workspace T";
        "alt-shift-s" = "move-node-to-workspace S";
        "alt-shift-m" = "move-node-to-workspace M";
        "alt-shift-o" = "move-node-to-workspace O";
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
