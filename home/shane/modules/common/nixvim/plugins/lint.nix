{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    shellcheck
  ];

  plugins.lint = {
    enable = true;
    lintersByFt = {
      sh = [ "shellcheck" ];
      bash = [ "shellcheck" ];
    };
    autoCmd = {
      event = [ "BufWritePost" "InsertLeave" ];
      callback.__raw = ''
        function()
          require("lint").try_lint()
        end
      '';
    };
  };
}
