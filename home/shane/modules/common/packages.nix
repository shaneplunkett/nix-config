{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jq
    bat
    lsd
    lazygit
    starship
    neofetch
    obsidian
    vesktop
    go
    lazydocker
    opencode

    nixfmt
    black
    pyright
    gopls
    stylua
    prettier

    nixd
    nil
    lua-language-server
    typescript-language-server
    bash-language-server
    astro-language-server
    docker-language-server
    gopls
    terraform-ls
    vscode-langservers-extracted
    markdown-oxide
    ruff
    yaml-language-server
    omnisharp-roslyn
    tailwindcss-language-server
    phpactor
    rubyPackages_3_3.ruby-lsp
    sqls
    glsl_analyzer
  ];
}
