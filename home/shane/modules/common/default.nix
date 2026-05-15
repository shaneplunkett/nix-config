{ ... }:
{
  imports = [
    # CLI wrappers (aikido, atlassian, browserbase, coderabbit, gws,
    # himalaya, langsmith, slack, tavily, todoist, unifi, vex-cli) now
    # live in vex-tooling and arrive via home-manager `sharedModules`.

    ./age.nix
    ./ai
    ./btop.nix
    ./git.nix
    ./ing-probe.nix
    ./lazygit.nix
    ./nixvim
    ./packages.nix
    ./rbw.nix
    ./ssh.nix
    ./terraform.nix
    ./terminal
    ./theme
    ./youtui
  ];
}
