{ inputs, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${stdenv.hostPlatform.system}.agenix

  ];

}
