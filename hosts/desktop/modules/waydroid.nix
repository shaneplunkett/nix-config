{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;

  # NixOS 6.18+ doesn't ship legacy iptables kernel modules, so waydroid's
  # net script must use nftables. Patch the hardcoded LXC_USE_NFT="false".
  nixpkgs.overlays = [
    (final: prev: {
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
    wl-clipboard # clipboard sharing between host and waydroid
  ];
}
