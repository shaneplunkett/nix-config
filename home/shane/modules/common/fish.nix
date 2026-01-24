{ ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "lsd";
      drs = "sudo darwin-rebuild switch --flake ~/nix-config";
      nrs = "sudo nixos-rebuild switch --flake ~/nix-config#desktop";
      ngc = "sudo nix-collect-garbage -d";
      tfp = "terraform plan";
      tfa = "terraform apply";
      tfaa = "terraform apply -auto-approve";
    };
    functions = {
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
      starship init fish | source
      set -gx PATH $HOME/go/bin $PATH

    '';
  };
}
