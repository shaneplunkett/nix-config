{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  nixpkgs.overlays = [
    (_final: prev: {
      waydroid = prev.waydroid.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace data/scripts/waydroid-net.sh \
            --replace-fail 'LXC_USE_NFT="false"' 'LXC_USE_NFT="true"'
        '';
      });
    })
  ];

  networking.nftables.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];
}
