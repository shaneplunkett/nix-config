# shellcheck shell=bash
set -u

CONFIG="${SESH_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/sesh/sesh.toml}"
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/sesh-picker.log"
FZF_THEME=(
  --ansi
  --no-separator
  --info=inline-right
  --prompt='workspace > '
  --pointer='▌'
  --marker='•'
  --scrollbar='▐▌'
  --color='bg:-1,bg+:#45475a,gutter:-1,fg:#cdd6f4,fg+:#f5c2e7,hl:#cba6f7,hl+:#f5c2e7,prompt:#f5c2e7,pointer:#f5c2e7,marker:#a6e3a1,header:#cba6f7,info:#89b4fa,query:#f5e0dc,spinner:#f9e2af'
)

list_workspaces() {
  sesh -C "$CONFIG" list -t -c -d 2>>"$LOG"
}

find_projects() {
  {
    printf '%s\n' "$HOME"
    printf '%s\n' "$HOME/nix-config"
    fd -H -t d -d 1 \
      -E .git -E node_modules -E .direnv -E .next -E dist \
      . "$HOME/projects/personal" "$HOME/projects/work" 2>/dev/null
  } | awk '!seen[$0]++'
}

pick_project() {
  find_projects | fzf "${FZF_THEME[@]}" \
    --no-sort \
    --prompt='project > ' \
    --height='100%'
}

rename_workspace() {
  local old_name=$1
  if ! tmux has-session -t "$old_name" 2>/dev/null; then
    printf 'Only live tmux sessions can be renamed.\n\nPress enter to return.'
    read -r _
    return
  fi

  printf 'Rename %s to: ' "$old_name"
  read -r new_name
  [ -z "$new_name" ] && return
  tmux rename-session -t "$old_name" "$new_name"
}

kill_workspace() {
  local name=$1
  if ! tmux has-session -t "$name" 2>/dev/null; then
    printf 'No live tmux session named %s.\n\nPress enter to return.' "$name"
    read -r _
    return
  fi

  printf 'Kill %s? [y/N] ' "$name"
  read -r confirm
  case "$confirm" in
    y|Y|yes|YES) tmux kill-session -t "$name" ;;
  esac
}

connect_workspace() {
  local name=$1
  [ -z "$name" ] && return
  sesh -C "$CONFIG" connect --switch "$name"
}

main() {
  mkdir -p "$(dirname "$LOG")"
  : >"$LOG"

  while true; do
    selection="$(
      list_workspaces | fzf "${FZF_THEME[@]}" \
        --no-sort \
        --header='ctrl-f find | ctrl-r rename | ctrl-d kill' \
        --header-first \
        --expect='ctrl-f,ctrl-r,ctrl-d'
    )"

    status=$?
    [ "$status" -ne 0 ] && exit "$status"

    key="$(printf '%s\n' "$selection" | sed -n '1p')"
    choice="$(printf '%s\n' "$selection" | sed -n '2p')"

    case "$key" in
      ctrl-f)
        project="$(pick_project)"
        [ -n "${project:-}" ] && sesh -C "$CONFIG" connect --switch "$project"
        exit $?
        ;;
      ctrl-r)
        [ -n "$choice" ] && rename_workspace "$choice"
        ;;
      ctrl-d)
        [ -n "$choice" ] && kill_workspace "$choice"
        ;;
      *)
        connect_workspace "$choice"
        exit $?
        ;;
    esac
  done
}

main
