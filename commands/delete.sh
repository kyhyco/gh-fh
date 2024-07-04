#!/usr/bin/env bash
set -e

__fh-delete() {
  branch_name=$1

  if [[ -n $branch_name ]]; then
    git checkout $branch_name
    exit 0
  fi

  local tags local_branches remote_branches target
  # get local branch names and add yellow prefix "local" to branch names
  local_branches=$(
    git --no-pager branch \
      --sort=-committerdate \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;33;1mlocal%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  # get remote branch names and add blue prefix "remote" to branch names
  target=$(
    (echo "$local_branches"; echo "$remote_branches"; echo "$tags") |
    fzf --no-sort --no-hscroll -m -n 2 \
        --ansi) || return

  # Open files on GitHub
  for branch in "${target[@]}"; do
    git branch -D $(awk '{print $2}' <<<"$branch" )
  done
}
