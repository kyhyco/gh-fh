#!/usr/bin/env bash
set -e

__fh-delete() {
  # get local branch names and add yellow prefix "local" to branch names
  local local_branches=$(
    git --no-pager branch \
      --sort=-committerdate \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;33;1mlocal%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return

  local upstream=$(git remote | grep -q upstream && echo upstream || echo origin)
  local main=$(git branch -l main master --format '%(refname:short)')
  local base_branch="$upstream/$main"
  if git remote | grep -qE "^(upstream|origin)$"; then
    base_branch="$main"
  fi
  local preview="git --no-pager log --color --graph --pretty=format:'%Cred%h%Creset %C(blue)<%an>%Creset %s -%C(bold yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit $base_branch..{2} | bat --color always --plain"

  # get remote branch names and add blue prefix "remote" to branch names
  local selection=$(
    (echo "$local_branches") | grep -v '^$' |
    fzf --no-sort --no-hscroll -m -n 2 \
        --preview="$preview" \
        --preview-window 'right,border-left,<30(hidden)' \
        --header="Press tab to multi select" \
        --ansi) || return

  if [[ -z "$selection" ]]; then
    echo "No branch deleted"
    exit 1
  fi

  # Open files on GitHub
  for branch in "${selection[@]}"; do
    git branch -D $(awk '{print $2}' <<<"$branch" )
  done
}
