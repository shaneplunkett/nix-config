#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
if [[ -d "$REPO_ROOT/skills" ]]; then
  SKILLS_DIR="$REPO_ROOT/skills"
  SHARED_DIR="$REPO_ROOT/shared"
elif [[ -d "$REPO_ROOT/plugins/autograb/skills" ]]; then
  SKILLS_DIR="$REPO_ROOT/plugins/autograb/skills"
  SHARED_DIR="$REPO_ROOT/plugins/autograb/shared"
else
  echo "Error: no supported AG skills layout found under $REPO_ROOT" >&2
  exit 1
fi
INSTALL_DIR="${1:-$HOME/.claude/skills}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

# Check dependencies
if ! command -v yq &>/dev/null; then
  echo -e "${RED}Error: 'yq' is required but not installed.${NC}" >&2
  exit 1
fi

# Determine what to install
TARGET="${2:-all}"
INSTALLED=()
ERRORS=()

install_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"
  local skill_md="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    echo -e "${YELLOW}  Skipping $skill_name — no SKILL.md found${NC}"
    return
  fi

  echo -e "  Installing ${BOLD}$skill_name${NC}..."

  local dest="$INSTALL_DIR/$skill_name"
  rm -rf "$dest"
  mkdir -p "$dest"

  # Copy SKILL.md
  cp "$skill_md" "$dest/SKILL.md"

  # Create references directory
  mkdir -p "$dest/references"

  # Copy skill-specific references (if any)
  local skill_refs_dir="$skill_dir/references"
  local has_local_refs=false
  if [[ -d "$skill_refs_dir" ]] && [[ -n "$(ls -A "$skill_refs_dir" 2>/dev/null)" ]]; then
    cp "$skill_refs_dir"/* "$dest/references/"
    has_local_refs=true
  fi

  # Parse shared_refs from SKILL.md frontmatter
  local frontmatter
  frontmatter="$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed '1d;$d')"

  local shared_refs
  shared_refs="$(echo "$frontmatter" | yq -r '.shared_refs // [] | .[]' 2>/dev/null || true)"

  if [[ -n "$shared_refs" ]]; then
    while IFS= read -r ref; do
      [[ -z "$ref" ]] && continue

      if [[ ! -f "$SHARED_DIR/$ref" ]]; then
        echo -e "${RED}  Error: shared ref '$ref' declared by $skill_name does not exist in shared/${NC}" >&2
        ERRORS+=("$skill_name: missing shared ref '$ref'")
        rm -rf "$dest"
        return
      fi

      if [[ "$has_local_refs" == true ]] && [[ -f "$skill_refs_dir/$ref" ]]; then
        if cmp -s "$SHARED_DIR/$ref" "$skill_refs_dir/$ref"; then
          continue
        else
          echo -e "${RED}  Error: collision in $skill_name — '$ref' exists in both shared/ and skill references/${NC}" >&2
          ERRORS+=("$skill_name: filename collision for '$ref'")
          rm -rf "$dest"
          return
        fi
      fi

      cp "$SHARED_DIR/$ref" "$dest/references/"
    done <<< "$shared_refs"
  fi

  # Remove references dir if empty
  if [[ -z "$(ls -A "$dest/references" 2>/dev/null)" ]]; then
    rmdir "$dest/references"
  fi

  INSTALLED+=("$skill_name")
}

echo ""
echo -e "${BOLD}AG AI Skills — Install${NC}"
echo -e "Target: ${BOLD}$INSTALL_DIR${NC}"
echo ""

if [[ "$TARGET" == "all" ]]; then
  for skill_dir in "$SKILLS_DIR"/*/; do
    [[ -d "$skill_dir" ]] && install_skill "$skill_dir"
  done
else
  local_skill_dir="$SKILLS_DIR/$TARGET"
  if [[ ! -d "$local_skill_dir" ]]; then
    echo -e "${RED}Error: skill '$TARGET' not found in skills/${NC}" >&2
    exit 1
  fi
  install_skill "$local_skill_dir"
fi

# Summary
echo ""
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo -e "${RED}${BOLD}Install failed with ${#ERRORS[@]} error(s):${NC}"
  for err in "${ERRORS[@]}"; do
    echo -e "${RED}  - $err${NC}"
  done
  exit 1
fi

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
  echo -e "${GREEN}${BOLD}Installed ${#INSTALLED[@]} skill(s):${NC}"
  for s in "${INSTALLED[@]}"; do
    echo -e "${GREEN}  ✓ $s${NC}"
  done
else
  echo -e "${YELLOW}No skills installed.${NC}"
fi
