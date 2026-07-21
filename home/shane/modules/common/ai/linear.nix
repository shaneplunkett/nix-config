{ pkgs, lib, ... }:
let
  rbwRuntimeEnv = ''
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      runtime_dir="/run/user/$(${pkgs.coreutils}/bin/id -u)"
      if [ -d "$runtime_dir" ]; then
        export XDG_RUNTIME_DIR="$runtime_dir"
      fi
    fi
  '';

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
