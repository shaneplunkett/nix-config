_: {
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        cc = "claude --dangerously-skip-permissions";
        ccr = "claude --dangerously-skip-permissions --resume";
        ccw = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude --dangerously-skip-permissions";
        ccwr = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude --dangerously-skip-permissions --resume";
        ccp = "CLAUDE_CONFIG_DIR=$HOME/.claude-pro claude";
        ccpr = "CLAUDE_CONFIG_DIR=$HOME/.claude-pro claude --resume";
        cx = "codex";
        cxr = "codex resume --last";
        cxw = "CODEX_HOME=$HOME/.codex-work codex";
        cxwr = "CODEX_HOME=$HOME/.codex-work codex resume --last";
      };
      shellAbbrs = {
        cat = "bat";
        ngc = "nh clean all --keep 3 --keep-since 7d --ask";
        tfi = "terraform init";
        tfp = "terraform plan";
        tfa = "terraform apply";
        tfaa = "terraform apply -auto-approve";
        nvl = "nvim --listen /tmp/nvim";
      };
      functions = {
        claude = "claude-restart $argv";
        nrs = ''
          if test (uname) = Darwin
            nh darwin switch $argv "$HOME/nix-config" -H (hostname -s)
          else
            nh os switch $argv "$HOME/nix-config" -H (hostname)
          end
        '';
        nrs-iter = ''
          set -l overrides \
            --override-input ag-ai-skills "path:$HOME/projects/work/ag-ai-skills" \
            --override-input ai-skills "path:$HOME/ai-skills" \
            --override-input nix-config-private "path:$HOME/projects/personal/nix-config-private"
          if test (uname) = Darwin
            nh darwin switch $argv "$HOME/nix-config" -H (hostname -s) -- $overrides
          else
            nh os switch $argv "$HOME/nix-config" -H (hostname) -- $overrides
          end
        '';
        tfc = ''
          set -l plan_file (mktemp -u --suffix=.tfplan)
          set -l plan_json (mktemp -u --suffix=.json)

          if terraform plan -out=$plan_file $argv
            terraform show -json $plan_file > $plan_json
            echo
            echo "── Cost impact ──────────────────────────────────"
            infracost diff --path $plan_json
          end

          rm -f $plan_file $plan_json
        '';
      };
      generateCompletions = true;
      interactiveShellInit = ''
        set fish_greeting
        set -gx PATH $HOME/go/bin $PATH
        set -gx LS_COLORS "di=38;2;180;190;254:ln=38;2;203;166;247:so=38;2;245;194;231:pi=38;2;242;205;205:ex=38;2;166;227;161:bd=38;2;249;226;175:cd=38;2;249;226;175:su=38;2;166;227;161;48;2;30;30;46:sg=38;2;166;227;161;48;2;30;30;46:tw=38;2;180;190;254;48;2;30;30;46:ow=38;2;180;190;254:st=38;2;180;190;254;48;2;30;30;46:or=38;2;243;139;168:mi=38;2;243;139;168;48;2;30;30;46:*.tar=38;2;250;179;135:*.gz=38;2;250;179;135:*.zip=38;2;250;179;135:*.7z=38;2;250;179;135:*.bz2=38;2;250;179;135:*.xz=38;2;250;179;135:*.zst=38;2;250;179;135:*.deb=38;2;250;179;135:*.rpm=38;2;250;179;135:*.nix=38;2;148;226;213:*.json=38;2;249;226;175:*.yaml=38;2;249;226;175:*.yml=38;2;249;226;175:*.toml=38;2;249;226;175:*.md=38;2;205;214;244:*.txt=38;2;205;214;244:*.rs=38;2;250;179;135:*.go=38;2;137;220;235:*.py=38;2;249;226;175:*.js=38;2;249;226;175:*.ts=38;2;137;180;250:*.lua=38;2;137;180;250:*.sh=38;2;166;227;161:*.fish=38;2;166;227;161"
        set -gx EZA_COLORS "ur=38;2;166;227;161:uw=38;2;249;226;175:ux=38;2;243;139;168:ue=38;2;243;139;168:gr=38;2;166;227;161:gw=38;2;249;226;175:gx=38;2;243;139;168:tr=38;2;166;227;161:tw=38;2;249;226;175:tx=38;2;243;139;168:sn=38;2;166;227;161:sb=38;2;166;227;161:nb=38;2;249;226;175:nk=38;2;166;227;161:nm=38;2;249;226;175:ng=38;2;250;179;135:nt=38;2;243;139;168:da=38;2;127;132;156:uu=38;2;180;190;254:gu=38;2;203;166;247:lp=38;2;203;166;247:ga=38;2;166;227;161:gm=38;2;249;226;175:gd=38;2;243;139;168:gv=38;2;148;226;213:gt=38;2;249;226;175"
      '';
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
