#!/bin/sh
# The one check for this repo. The agents' Stop hook, pre-commit and
# `scripts/check.sh` by hand all run exactly this, so there's one answer
# to "is the repo clean".
set -eu
cd "$(git rev-parse --show-toplevel)"

nix --option warn-dirty false fmt -- --check # nixfmt on every tracked .nix file, no rewrites
statix check .
deadnix --fail .
