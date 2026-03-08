{ pkgs, lib, ... }:
{
  extraPlugins = lib.mkIf pkgs.stdenv.isDarwin [
    (pkgs.vimUtils.buildVimPlugin {
      name = "xcodebuild-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "wojciech-kulik";
        repo = "xcodebuild.nvim";
        rev = "v7.0.0";
        hash = "sha256-+GeZzPf9aFufvszUDCFX8Osp4202c6p2hOeI2vbjYrc=";
      };
      # Optional integrations (fzf-lua, telescope, snacks picker) aren't hard deps
      nvimRequireCheck = "xcodebuild";
    })
  ];

  extraPackages = lib.mkIf pkgs.stdenv.isDarwin (with pkgs; [
    xcbeautify
  ]);

  extraConfigLua = lib.mkIf pkgs.stdenv.isDarwin ''
    require("xcodebuild").setup({})
  '';

  keymaps = lib.mkIf pkgs.stdenv.isDarwin [
    {
      mode = "n";
      key = "<leader>Xb";
      action = "<cmd>XcodebuildBuild<cr>";
      options.desc = "Build";
    }
    {
      mode = "n";
      key = "<leader>Xr";
      action = "<cmd>XcodebuildBuildRun<cr>";
      options.desc = "Build & Run";
    }
    {
      mode = "n";
      key = "<leader>Xt";
      action = "<cmd>XcodebuildTest<cr>";
      options.desc = "Run Tests";
    }
    {
      mode = "n";
      key = "<leader>XT";
      action = "<cmd>XcodebuildTestSelected<cr>";
      options.desc = "Run Current Test";
    }
    {
      mode = "n";
      key = "<leader>Xd";
      action = "<cmd>XcodebuildSelectDevice<cr>";
      options.desc = "Pick Device";
    }
    {
      mode = "n";
      key = "<leader>Xs";
      action = "<cmd>XcodebuildSelectScheme<cr>";
      options.desc = "Pick Scheme";
    }
    {
      mode = "n";
      key = "<leader>Xl";
      action = "<cmd>XcodebuildToggleLogs<cr>";
      options.desc = "Toggle Build Logs";
    }
    {
      mode = "n";
      key = "<leader>Xc";
      action = "<cmd>XcodebuildCleanBuild<cr>";
      options.desc = "Clean Build";
    }
    {
      mode = "n";
      key = "<leader>Xp";
      action = "<cmd>XcodebuildShowCurrentConfig<cr>";
      options.desc = "Show Config";
    }
    {
      mode = "n";
      key = "<leader>Xi";
      action = "<cmd>XcodebuildSetup<cr>";
      options.desc = "Setup Project";
    }
  ];
}
