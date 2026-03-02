{ pkgs, ... }:
{
  home.packages = [ pkgs.youtui ];

  home.file.".config/youtui/config.toml".source = ./youtui-config.toml;
}
