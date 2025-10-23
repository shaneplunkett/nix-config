{ ... }:
{
  xdg.desktopEntries = {
    claude-web = {
      name = "Claude-Web";
      exec = "chromium --app=https://claude.ai --class=claude";
      icon = "${icons/claude.png}";
      categories = [
        "Office"
      ];
    };

    chatgpt = {
      name = "ChatGPT";
      exec = "chromium --app=https://chatgpt.com --class=chatgpt";
      icon = "${icons/chatgpt.png}";
      categories = [
        "Office"
      ];
    };
  };
}
