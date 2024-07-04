#!/usr/bin/env bash
set -e

__fh-prune() {
  local upstream=$(git remote | grep -q upstream && echo upstream || echo origin)
  git remote prune $upstream | grep -o '\[pruned\] origin\/.*$' | sed -e 's/\[pruned\] origin\///' | grep -v 'error: ' | xargs git branch -D
}
