{ pkgs }:
{
  aikido-mcp = pkgs.callPackage ./aikido-mcp { };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
  xero-mcp-server = pkgs.callPackage ./xero-mcp-server { };
}
