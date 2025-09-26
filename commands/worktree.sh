#!/usr/bin/env bash
set -e

__fh-list-worktrees() {
    git worktree list --porcelain | awk '
    BEGIN {
        FS = " "
        yellow = "\033[33m"
        purple = "\033[35m"
        reset = "\033[0m"
    }
    /^worktree / {
        path = $2
        split(path, parts, "/")
        name = parts[length(parts)]
        if (name == "main") {
            name = "main"
        } else if (parts[length(parts)-1] == "pull") {
            name = parts[length(parts)-1] "/" parts[length(parts)]
        }
    }
    /^branch / {
        split($0, branch, "/")
        printf "%sworktree%s %-15s %sbranch%s %s\n", yellow, reset, name, purple, reset, branch[length(branch)]
    }
    ' | sort
}

__fh-worktree-add() {
  local root_dir=$(git rev-parse --git-common-dir)
  cd "$root_dir"
  git worktree add "$1" > /dev/null 2>&1
  echo "Added worktree: $1"
}

__fh-worktree-path() {
  local selection=$(__fh-list-worktrees |
    fzf --no-sort --no-hscroll --no-multi \
        --ansi) || return
  local worktree=$(echo "$selection" | awk '{print $2}')

  local common_dir=$(git rev-parse --git-common-dir)
  echo "$common_dir/$worktree"
}

__fh-worktree-delete() {
  echo "worktree delete"
}

__fh-worktree() {
  local git_dir=$(git rev-parse --git-dir)
  local common_dir=$(git rev-parse --git-common-dir)

  if [[ "$git_dir" == "$common_dir" ]]; then
    echo "Not in a bare worktree"
    exit 0
  fi

  if [[ $1 == "add" ]]; then
    shift
    rest=("$@")
    __fh-worktree-add "${rest[@]}"

  elif [[ $1 == "path" ]]; then
    __fh-worktree-path

  elif [[ $1 == "delete" ]]; then
    __fh-worktree-delete

  else
    echo "Usage: fh worktree <option>"
    echo ""
    echo "Options:"
    echo "  add        - Add a worktree"
    echo "  delete     - Delete a worktree"
    echo "  path       - Print worktree path"
  fi
}
