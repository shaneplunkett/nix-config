{ ... }:
{

  programs.opencode.settings.mcp.mcphub = {
    type = "remote";
    url = "https://mcphub.tail1d49f8.ts.net/mcp/$smart";
    enabled = true;
  };

  programs.opencode.settings.permission."mcphub*" = "allow";

}
