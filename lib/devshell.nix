# The dev shell direnv loads in this repo. The short commands stand in for
# a justfile: each is a tiny script on PATH, since direnv can export PATH
# but not shell aliases. With no host they act on this machine.
pkgs:
let
  remote =
    name: mode:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.git ];
      text = ''
        root="$(git rev-parse --show-toplevel)"
        exec "$root/scripts/remote.sh" ${mode} "''${1:-$(hostname -s)}"
      '';
    };

  check = pkgs.writeShellApplication {
    name = "check";
    runtimeInputs = [ pkgs.git ];
    text = ''exec "$(git rev-parse --show-toplevel)/scripts/check.sh" "$@"'';
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    (remote "switch" "switch")
    (remote "build" "build")
    (remote "evaluate" "eval")
    check

    bashInteractive
    coreutils
    deadnix
    fd
    git
    jq
    manix
    nh
    nil
    nix-init
    nix-output-monitor
    nix-update
    nixfmt
    nurl
    ripgrep
    rsync
    shellcheck
    shfmt
    statix
  ];
}
