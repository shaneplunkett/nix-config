{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ngc = "sudo nix-collect-garbage -d";
      tfi = "terraform init";
      tfp = "terraform plan";
      tfa = "terraform apply";
      tfaa = "terraform apply -auto-approve";
      nvl = "nvim --listen /tmp/nvim";

      # Claude Code — personal account
      cc = "claude --allow-dangerously-skip-permissions";
      ccr = "claude --resume --allow-dangerously-skip-permissions";

      # Claude Code — work account
      ccw = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude --allow-dangerously-skip-permissions";
      ccwr = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude --resume --allow-dangerously-skip-permissions";
    };
    functions = {
      nrs = ''
        if test (uname) = Darwin
          sudo darwin-rebuild switch --flake ~/nix-config
        else
          sudo nixos-rebuild switch --flake ~/nix-config
        end
      '';
      prettyjson = ''
        jq -R -r '. as $line | try (fromjson | 
            "\u001b[36m\(.level | ascii_upcase)\u001b[0m \u001b[35m[\(.module // "unknown")]\u001b[0m \(.message) \(if .operation_name then "\u001b[33m(\(.operation_name))\u001b[0m" else "" end)" + 
            (if .error then "\n  \u001b[31m❌ Error:\u001b[0m \(.error.message // .formattedError.message)" else "" end) + 
            (if .formattedError.extensions.stacktrace then "\n  \u001b[90m📚 Stack:\u001b[0m\n    " + (.formattedError.extensions.stacktrace | join("\n    ")) else "" end) + 
            (if .statusCode then "\n  \u001b[33m🔢 Status:\u001b[0m \(.statusCode)" else "" end) + 
            (if .duration then "\n  \u001b[36m⏱️  Duration:\u001b[0m \(.duration)ms" else "" end) + 
            (if .user_id then "\n  \u001b[35m👤 User:\u001b[0m \(.user_id)" else "" end) +
            (if .level == "error" then "\n  \u001b[90m📦 Full context:\u001b[0m\n\u001b[90m" + (. | @json) + "\u001b[0m" else "" end)
        ) catch $line'
      '';
    };
    generateCompletions = true;
    interactiveShellInit = ''
      set fish_greeting
      set -gx PATH $HOME/go/bin $PATH

      # Catppuccin Mocha — file type colours via LS_COLORS (truecolour)
      # eza reads LS_COLORS for file types, EZA_COLORS for metadata
      set -gx LS_COLORS "di=38;2;180;190;254:ln=38;2;203;166;247:so=38;2;245;194;231:pi=38;2;242;205;205:ex=38;2;166;227;161:bd=38;2;249;226;175:cd=38;2;249;226;175:su=38;2;166;227;161;48;2;30;30;46:sg=38;2;166;227;161;48;2;30;30;46:tw=38;2;180;190;254;48;2;30;30;46:ow=38;2;180;190;254:st=38;2;180;190;254;48;2;30;30;46:or=38;2;243;139;168:mi=38;2;243;139;168;48;2;30;30;46:*.tar=38;2;250;179;135:*.gz=38;2;250;179;135:*.zip=38;2;250;179;135:*.7z=38;2;250;179;135:*.bz2=38;2;250;179;135:*.xz=38;2;250;179;135:*.zst=38;2;250;179;135:*.deb=38;2;250;179;135:*.rpm=38;2;250;179;135:*.nix=38;2;148;226;213:*.json=38;2;249;226;175:*.yaml=38;2;249;226;175:*.yml=38;2;249;226;175:*.toml=38;2;249;226;175:*.md=38;2;205;214;244:*.txt=38;2;205;214;244:*.rs=38;2;250;179;135:*.go=38;2;137;220;235:*.py=38;2;249;226;175:*.js=38;2;249;226;175:*.ts=38;2;137;180;250:*.lua=38;2;137;180;250:*.sh=38;2;166;227;161:*.fish=38;2;166;227;161"

      # Catppuccin Mocha — eza metadata colours
      # ur/gr=read uw/gw=write ux/gx=exec — permissions
      # sn/sb=size number/unit  da=date  uu/gu=user/group  lp=symlink path
      # ga/gm/gd/gv/gt=git added/modified/deleted/renamed/type-change
      set -gx EZA_COLORS "ur=38;2;166;227;161:uw=38;2;249;226;175:ux=38;2;243;139;168:ue=38;2;243;139;168:gr=38;2;166;227;161:gw=38;2;249;226;175:gx=38;2;243;139;168:tr=38;2;166;227;161:tw=38;2;249;226;175:tx=38;2;243;139;168:sn=38;2;166;227;161:sb=38;2;166;227;161:nb=38;2;249;226;175:nk=38;2;166;227;161:nm=38;2;249;226;175:ng=38;2;250;179;135:nt=38;2;243;139;168:da=38;2;127;132;156:uu=38;2;180;190;254:gu=38;2;203;166;247:lp=38;2;203;166;247:ga=38;2;166;227;161:gm=38;2;249;226;175:gd=38;2;243;139;168:gv=38;2;148;226;213:gt=38;2;249;226;175"
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };
}
