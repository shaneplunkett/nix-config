{
  pkgs,
  lib,
  aiHelpers,
  ...
}:
let
  inherit (aiHelpers) rbwRuntimeEnv;

  linear = pkgs.writeShellApplication {
    name = "linear";
    runtimeInputs = [ pkgs.rbw ];
    text = ''
      case "''${1:-}" in
        --help|-h|--version)
          exec ${lib.getExe pkgs.linear-cli} "$@"
          ;;
      esac

      if [ "''${1:-}" = "auth" ]; then
        case "''${2:-}" in
          login|migrate|token)
            echo "linear: authentication is managed by Nix and the linear-api-key Bitwarden entry" >&2
            exit 2
            ;;
        esac
      fi

      ${rbwRuntimeEnv}

      if ! linear_api_key="$(rbw get linear-api-key 2>/dev/null)" || [ -z "$linear_api_key" ]; then
        echo "linear: couldn't load the linear-api-key Bitwarden entry; check rbw is unlocked and the entry exists" >&2
        exit 1
      fi

      export LINEAR_API_KEY="$linear_api_key"
      exec ${lib.getExe pkgs.linear-cli} "$@"
    '';
  };
in
{
  home.packages = [ linear ];
}
