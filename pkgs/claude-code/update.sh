#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
base_url="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
version="${1:-$(curl -fsSL "$base_url/latest")}"

curl -fsSL "$base_url/$version/manifest.json" \
  --output "$repo_root/pkgs/claude-code/manifest.json"
