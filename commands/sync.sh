#!/usr/bin/env bash
set -e

__fh-sync() {
  # check for untracked files
  if [[ -z $(git status -s) ]]; then

    # check if upstream remote repository exists
    local upstream=$(git remote | grep upstream)
    if [[ -z "$upstream" ]]; then
      # use origininstead of upstream
      upstream=origin
    fi

    local main=$(git branch -l main master --format '%(refname:short)')

    if [[ -z "$main" ]]; then
      echo "Error: missing main or master branch"
      exit 1
    fi

    echo "Syncing $main branch"
    echo ""

    git fetch $upstream

    # Check if the current branch is main and pull
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "$main" ]]; then
      git pull $upstream $main
    else
      git branch -f $main $upstream/$main
    fi

    if [[ "$upstream" != "origin" ]]; then
      git push origin $main:$main
    fi
  else
    # force user to save untracked changes
    echo "Warn: there are untracked changes; please save your changes"
    exit 1
  fi
}
