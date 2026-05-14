{ pkgs, ... }:
let
  bucket = "ag-gemini-dev-5b34-reports";
  urlBase = "https://storage.googleapis.com/${bucket}";

  vexReportPublish = pkgs.writeShellApplication {
    name = "vex-report-publish";
    runtimeInputs = [
      pkgs.google-cloud-sdk
      pkgs.coreutils
    ];
    text = ''
      BUCKET="${bucket}"
      URL_BASE="${urlBase}"

      usage() {
        cat <<USAGE
      Usage: vex-report-publish <html-file> [--name <remote-name>]

        <html-file>           Local path to HTML file to publish.
        --name <remote-name>  Use exact remote object name. Default is
                              <basename>-<UTC-timestamp>.html so each publish
                              gets a unique URL. Pass --name to overwrite a
                              stable URL in place (e.g. an updating dashboard).

      Prints the public URL on stdout. Logs upload progress on stderr.

      Bucket: $BUCKET (Melbourne, public read, 30-day object TTL)
      USAGE
      }

      if [ $# -lt 1 ]; then
        usage >&2
        exit 2
      fi

      local_file=""
      remote_name=""

      while [ $# -gt 0 ]; do
        case "$1" in
          -h|--help)
            usage
            exit 0
            ;;
          --name)
            if [ $# -lt 2 ]; then
              echo "vex-report-publish: --name requires a value" >&2
              exit 2
            fi
            remote_name="$2"
            shift 2
            ;;
          --name=*)
            remote_name="''${1#--name=}"
            shift
            ;;
          -*)
            echo "vex-report-publish: unknown flag: $1" >&2
            usage >&2
            exit 2
            ;;
          *)
            if [ -z "$local_file" ]; then
              local_file="$1"
            else
              echo "vex-report-publish: unexpected extra argument: $1" >&2
              exit 2
            fi
            shift
            ;;
        esac
      done

      if [ -z "$local_file" ]; then
        echo "vex-report-publish: missing <html-file>" >&2
        usage >&2
        exit 2
      fi

      if [ ! -f "$local_file" ]; then
        echo "vex-report-publish: file not found: $local_file" >&2
        exit 1
      fi

      if [ -z "$remote_name" ]; then
        base="$(basename "$local_file" .html)"
        ts="$(date -u +%Y%m%d-%H%M%S)"
        remote_name="''${base}-''${ts}.html"
      fi

      # Always serve as UTF-8 HTML so reports don't mojibake (lesson burned
      # 2026-05-14). Short cache so updates are visible quickly when --name
      # is used to overwrite a stable URL.
      gcloud storage cp "$local_file" "gs://$BUCKET/$remote_name" \
        --content-type='text/html; charset=utf-8' \
        --cache-control='public, max-age=300' >&2

      printf '%s/%s\n' "$URL_BASE" "$remote_name"
    '';
  };
in
{
  home.packages = [ vexReportPublish ];
}
