{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    shellcheck
    tflint
  ];

  plugins.lint = {
    enable = true;
    lintersByFt = {
      sh = [ "shellcheck" ];
      bash = [ "shellcheck" ];
      terraform = [ "tflint" ];
      hcl = [ "tflint" ];
      tf = [ "tflint" ];
    };
    autoCmd = {
      event = [
        "BufWritePost"
        "InsertLeave"
      ];
      callback.__raw = ''
        function()
          require("lint").try_lint()
        end
      '';
    };
  };
}
