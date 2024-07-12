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

  # $branch exists
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

  local choices=$(echo "$local_branches"; echo "$remote_branches"; echo "$tags"; echo "");

  local upstream=$(git remote | grep -q upstream && echo upstream || echo origin)
  local main=$(git branch -l main master --format '%(refname:short)')
  local base_branch="$upstream/$main"
  if git remote | grep -qE "^(upstream|origin)$"; then
    base_branch="$main"
  fi
  local preview="git --no-pager log --color --graph --pretty=format:'%Cred%h%Creset %C(blue)<%an>%Creset %s -%C(bold yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit $base_branch..{2} | bat --color always --plain"

  local selection=$(
    echo "$choices" |
    fzf --no-sort --no-hscroll --no-multi -n 2 \
        --preview="$preview" \
        --preview-window 'right,border-left,<30(hidden)' \
        --ansi) || return


  if [[ -z $selection ]]; then
    echo "No branch selected"
    exit 1
  fi

  local type=$(echo "$selection" | awk '{print $1}')
  local selected_branch=$(echo "$selection" | awk '{print $2}')

  # branch type: remote
  if [[ "$type" == "remote" ]]; then
    local remote=$(__fh-first-group $selected_branch)
    local branch_name=""

    if [[ "$remote" == "origin" ]]; then
      branch_name=$(__fh-remove-first-slash $selected_branch)
    else
      branch_name="remote/$selected_branch"
    fi

    # create new branch if it doesn't exist
    if ! git show-ref --quiet "refs/heads/$branch_name"; then
      git checkout --quiet -b $branch_name "refs/remotes/$selected_branch"
      echo "On branch: $branch_name"
      exit 0
    fi

    git checkout --quiet $branch_name
    echo "On branch: $branch_name"
    exit 0
  fi

  local branch_name=$(echo "$selected_branch")

  # branch type: tag
  if [[ "$type" == "tag" ]]; then
    branch_name="tag/$selected_branch"
    git checkout --quiet "$selected_branch"
    echo "On tag: $branch_name"
    exit 0
  fi

  git checkout --quiet "$selected_branch"
  echo "On branch: $branch_name"
}
