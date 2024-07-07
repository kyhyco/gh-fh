#!/usr/bin/env bash
set -e

__fh-remove-first-slash() {
  local input="$1"
  echo "${input#*/}"
}

__fh-first-group() {
  local input_string="$1"
  local first_group="${input_string%%/*}"
  echo "$first_group"
}

__fh-checkout() {
  branch=$1

  if [[ -n $branch ]]; then
    git checkout $branch
    exit 0
  fi

  # get local branch names and add yellow prefix "local" to branch names
  local local_branches=$(
    git --no-pager branch \
      --sort=-committerdate \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;33;1mlocal%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return

  # get remote branch names and add blue prefix "remote" to branch names
  local remote_branches=$(
    git --no-pager branch \
      --remote \
      --sort=-committerdate \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mremote%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return

  # get tag names and add purple prefix "remote" to branch names
  local tags=$(git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return

  local selection=$(
    (echo "$local_branches"; echo "$remote_branches"; echo "$tags") |
    fzf --no-sort --no-hscroll --no-multi -n 2 \
        --ansi) || return

  if [[ -z $selection ]]; then
    echo "No branch selected"
    exit 1
  fi

  local type=$(awk '{print $1}' <<<"$selection")
  local full_path=$(awk '{print $2}' <<<"$selection")

  if [[ "$type" == "remote" ]]; then
    local remote=$(__fh-first-group $full_path)
    local branch_name=""

    if [[ "$remote" == "origin" ]]; then
      branch_name=$(__fh-remove-first-slash $full_path)
    else
      branch_name="remote/$full_path"
    fi

    # create new branch if it doesn't exist
    if ! git show-ref --quiet "refs/heads/$branch_name"; then
      git checkout -b $branch_name "refs/remotes/$full_path"
      exit 0
    fi

    git checkout $branch_name
    exit 0
  fi

  git checkout "$full_path"
}
