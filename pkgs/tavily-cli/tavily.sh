#!/usr/bin/env bash
# tavily — thin CLI around the Tavily search + extract API.
# Auth: reads TAVILY_API_KEY from env (set by the home-manager wrapper from agenix).

set -euo pipefail

TAVILY_API_BASE="${TAVILY_API_BASE:-https://api.tavily.com}"

usage() {
  cat <<'EOF'
Usage: tavily <command> [options]

Commands:
  search <query>       Search the web (LLM-optimised, returns content not just links)
  extract <url>...     Extract clean content from one or more URLs
  help [command]       Show help (per-command help with `tavily help search`)

Output is single-line JSON by default; pass --pretty for human-readable.
Run `tavily help <command>` for command-specific options.
EOF
}

require_key() {
  if [ -z "${TAVILY_API_KEY:-}" ]; then
    echo "tavily: TAVILY_API_KEY is not set" >&2
    echo "tavily: ensure the home-manager wrapper is loading it from agenix, or export it manually" >&2
    exit 1
  fi
}

post_json() {
  local path="$1"
  local body="$2"
  curl -sS -X POST "${TAVILY_API_BASE}${path}" \
    -H "Authorization: Bearer ${TAVILY_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$body"
}

check_error() {
  local response="$1"
  if printf '%s' "$response" | jq -e '.error // .detail // empty' >/dev/null 2>&1; then
    echo "tavily: API error" >&2
    printf '%s' "$response" | jq . >&2 || printf '%s\n' "$response" >&2
    exit 1
  fi
}

cmd_search() {
  require_key
  local query=""
  local depth="basic"
  local max_results=5
  local include_answer=false
  local include_raw=false
  local include_domains=""
  local exclude_domains=""
  local topic="general"
  local time_range=""
  local pretty=false

  while [ $# -gt 0 ]; do
    case "$1" in
      --depth) depth="$2"; shift 2 ;;
      --max-results) max_results="$2"; shift 2 ;;
      --answer) include_answer=true; shift ;;
      --raw) include_raw=true; shift ;;
      --include-domains) include_domains="$2"; shift 2 ;;
      --exclude-domains) exclude_domains="$2"; shift 2 ;;
      --topic) topic="$2"; shift 2 ;;
      --time-range) time_range="$2"; shift 2 ;;
      --pretty) pretty=true; shift ;;
      --help|-h) help_search; exit 0 ;;
      --) shift; break ;;
      --*) echo "tavily search: unknown flag $1" >&2; exit 2 ;;
      *)
        if [ -z "$query" ]; then query="$1"; else query="$query $1"; fi
        shift
        ;;
    esac
  done

  # Slurp any remaining positional args after `--` as part of the query.
  while [ $# -gt 0 ]; do
    if [ -z "$query" ]; then query="$1"; else query="$query $1"; fi
    shift
  done

  if [ -z "$query" ]; then
    echo "tavily search: query required" >&2
    help_search >&2
    exit 2
  fi

  local body
  body=$(jq -n \
    --arg q "$query" \
    --arg depth "$depth" \
    --argjson max "$max_results" \
    --argjson answer "$include_answer" \
    --argjson raw "$include_raw" \
    --arg topic "$topic" \
    '{query: $q, search_depth: $depth, max_results: $max, include_answer: $answer, include_raw_content: $raw, topic: $topic}')

  if [ -n "$include_domains" ]; then
    body=$(printf '%s' "$body" | jq --arg d "$include_domains" '. + {include_domains: ($d | split(","))}')
  fi
  if [ -n "$exclude_domains" ]; then
    body=$(printf '%s' "$body" | jq --arg d "$exclude_domains" '. + {exclude_domains: ($d | split(","))}')
  fi
  if [ -n "$time_range" ]; then
    body=$(printf '%s' "$body" | jq --arg t "$time_range" '. + {time_range: $t}')
  fi

  local response
  response=$(post_json "/search" "$body")
  check_error "$response"

  if $pretty; then
    printf '%s' "$response" | jq -r '
      (if .answer and (.answer | length > 0) then "ANSWER:\n" + .answer + "\n\n" else "" end) +
      "RESULTS:\n\n" +
      ([.results[] | "• " + (.title // "(untitled)") + "\n  " + .url + "\n  " + ((.content // "") | gsub("\\s+"; " ")) + "\n"] | join("\n"))
    '
  else
    printf '%s\n' "$response"
  fi
}

cmd_extract() {
  require_key
  local urls=()
  local depth="basic"
  local include_raw=false
  local pretty=false

  while [ $# -gt 0 ]; do
    case "$1" in
      --depth) depth="$2"; shift 2 ;;
      --raw) include_raw=true; shift ;;
      --pretty) pretty=true; shift ;;
      --help|-h) help_extract; exit 0 ;;
      --) shift; break ;;
      --*) echo "tavily extract: unknown flag $1" >&2; exit 2 ;;
      *) urls+=("$1"); shift ;;
    esac
  done

  while [ $# -gt 0 ]; do
    urls+=("$1")
    shift
  done

  if [ ${#urls[@]} -eq 0 ]; then
    echo "tavily extract: at least one URL required" >&2
    help_extract >&2
    exit 2
  fi

  local urls_json
  urls_json=$(printf '%s\n' "${urls[@]}" | jq -R . | jq -s .)

  local body
  body=$(jq -n \
    --argjson urls "$urls_json" \
    --arg depth "$depth" \
    --argjson raw "$include_raw" \
    '{urls: $urls, extract_depth: $depth, include_raw_content: $raw}')

  local response
  response=$(post_json "/extract" "$body")
  check_error "$response"

  if $pretty; then
    printf '%s' "$response" | jq -r '
      (.results // [])[] |
        "URL: " + .url + "\n\n" + ((.raw_content // .content // "") | gsub("\\r"; "")) + "\n\n---\n"
    '
  else
    printf '%s\n' "$response"
  fi
}

help_search() {
  cat <<'EOF'
Usage: tavily search <query> [options]

Search the web with Tavily (LLM-optimised — returns extracted content per result,
not just links).

Options:
  --depth <basic|advanced>       Search depth (default: basic)
  --max-results <n>              Number of results (default: 5)
  --answer                       Include LLM-synthesised answer across results
  --raw                          Include raw page content per result
  --include-domains <csv>        Comma-separated allowlist of domains
  --exclude-domains <csv>        Comma-separated blocklist of domains
  --topic <general|news>         Search topic (default: general)
  --time-range <day|week|month|year>
                                 Restrict to recent results
  --pretty                       Human-readable output (default: single-line JSON)

Examples:
  tavily search "Tavily vs Exa for AI agents"
  tavily search "Sydney housing market" --topic news --time-range month --pretty
  tavily search "claude opus 4 release notes" --depth advanced --answer --pretty
  tavily search "POTS treatment 2026" --include-domains nih.gov,mayoclinic.org --pretty
EOF
}

help_extract() {
  cat <<'EOF'
Usage: tavily extract <url> [<url>...] [options]

Extract clean content from one or more URLs (Tavily's /extract endpoint).

Options:
  --depth <basic|advanced>       Extraction depth (default: basic)
  --raw                          Include raw page content
  --pretty                       Human-readable output (default: single-line JSON)

Examples:
  tavily extract https://example.com/article
  tavily extract https://a.com https://b.com --depth advanced --pretty
EOF
}

main() {
  if [ $# -eq 0 ]; then
    usage
    exit 0
  fi

  local cmd="$1"; shift
  case "$cmd" in
    search) cmd_search "$@" ;;
    extract) cmd_extract "$@" ;;
    help|--help|-h)
      if [ $# -eq 0 ]; then
        usage
      else
        case "$1" in
          search) help_search ;;
          extract) help_extract ;;
          *) usage ;;
        esac
      fi
      ;;
    *)
      echo "tavily: unknown command: $cmd" >&2
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
