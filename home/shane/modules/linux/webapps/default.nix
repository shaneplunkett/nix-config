{ pkgs, lib, ... }:
let
  profiles = {
    personal = "Default";
    work = "Profile 1";
  };
  mkWebApp =
    {
      name,
      url,
      profile ? "personal",
      icon ? null,
      categories ? [ "Network" ],
      class ? builtins.replaceStrings [ " " ] [ "-" ] (lib.toLower name),
    }:
    {
      inherit name categories;
      icon = if icon != null then icon else name;
      exec = lib.concatStringsSep " " [
        "${pkgs.google-chrome}/share/google/chrome/google-chrome"
        "--app=${url}"
        "--class=${class}"
        "--profile-directory=${profiles.${profile}}"
      ];
      type = "Application";
      settings.StartupWMClass = class;
    };
in
{
  xdg.desktopEntries = {
    slack = mkWebApp {
      name = "Slack";
      url = "https://autograb.slack.com";
      profile = "work";
      icon = ./icons/slack.png;
      categories = [ "Office" ];
    };
    chatgpt = mkWebApp {
      name = "ChatGPT";
      url = "https://chat.openai.com";
      profile = "personal";
      icon = ./icons/chatgpt.png;
      categories = [ "Office" ];
    };
    claude-web = mkWebApp {
      name = "Claude";
      url = "https://claude.ai";
      profile = "personal";
      icon = ./icons/claude.png;
      categories = [ "Office" ];
    };
  };
}
