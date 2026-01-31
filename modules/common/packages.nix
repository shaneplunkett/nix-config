{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    agenix-cli
  ];

}
