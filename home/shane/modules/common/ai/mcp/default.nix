{
  pkgs,
  ...
}:
let
  inherit (pkgs) nodejs;

  aikidoMcpServer = pkgs.buildNpmPackage rec {
    pname = "aikido-mcp";
    version = "1.0.7";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@aikidosec/mcp/-/mcp-${version}.tgz";
      hash = "sha256-/G9PY0526/r1kcapSgWK8FbpDAsodzm0OrrkfnL4MCY=";
    };

    sourceRoot = "package";
    npmDepsHash = "sha256-V0RpcQJKHKsEF21NCBYDRud2wE+I7L7Gwpvb7u6WtTw=";
    dontNpmBuild = true;
  };

  aikidoWrapper = pkgs.writeShellApplication {
    name = "aikido-mcp-wrapper";
    runtimeInputs = [
      pkgs.rbw
      aikidoMcpServer
    ];
    text = ''
      AIKIDO_API_KEY="$(rbw get aikido-token 2>/dev/null)"
      export AIKIDO_API_KEY
      exec aikido-mcp
    '';
  };

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

      aikido = {
        command = "${aikidoWrapper}/bin/aikido-mcp-wrapper";
        args = [ ];
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
