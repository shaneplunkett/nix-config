{
  pkgs,
  ...
}:
let
  inherit (pkgs) nodejs;

  xeroMcpServer = pkgs.buildNpmPackage rec {
    pname = "xero-mcp-server";
    version = "0.0.16";

    src = pkgs.fetchFromGitHub {
      owner = "XeroAPI";
      repo = "xero-mcp-server";
      rev = "1b2e9b332086fa0887c8248010b4bc75083491d1";
      hash = "sha256-KJpS7Lw1xQBteZlv3O05u8mASnarPU8ebyXIxTJbwkw=";
    };

    npmDepsHash = "sha256-ifbjeO3V+eQv7dwFbSFq17AlklcsjqJ2WslySWFwUlk=";
  };

  xeroWrapper = pkgs.writeShellApplication {
    name = "xero-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      xeroMcpServer
    ];
    text = ''
      XERO_CLIENT_ID="$(rbw get xero-client-id 2>/dev/null)"
      XERO_CLIENT_SECRET="$(rbw get xero-client-secret 2>/dev/null)"
      export XERO_CLIENT_ID XERO_CLIENT_SECRET
      exec xero-mcp-server
    '';
  };

in
{
  programs.mcp = {
    enable = true;

    servers = {
      # Desktop-only: direct local connections.
      neovim = {
        command = "${nodejs}/bin/npx";
        args = [
          "-y"
          "mcp-neovim-server"
        ];
        env = {
          NVIM_SOCKET_PATH = "/tmp/nvim";
        };
      };

      xero = {
        command = "${xeroWrapper}/bin/xero-mcp-wrapper";
        args = [ ];
      };
    };
  };

  home.packages = [
    nodejs
  ];
}
