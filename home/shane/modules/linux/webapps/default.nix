{ ... }:
{
  xdg.desktopEntries.claude = {
    name = "Claude";
    exec = "chromium --app=https://claude.ai --class=claude";
    icon = "./icons/claude.png";
    categories = [
      "Network"
      "Office"
    ];
    startupWMClass = "claude";
  };
}
