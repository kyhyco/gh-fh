#!/usr/bin/env bash
set -e

source "$FUZZYHUB_DIR/commands/utils/remote-url.sh"

__fh-view() {
  local url=$(__fh-remote-url)

  local files=("$@")
  local main=$(git branch -l main master --format '%(refname:short)')

  if [[ -z "$main" ]]; then
    echo "Error: missing main or master branch"
    exit 1
  fi

  # Open folder on GitHub
  if [[ ${#files[@]} -eq 0 ]]; then
    open "$url/tree/$main"
  else
    # Open files on GitHub
    for file in "${files[@]}"; do
      open "$url/blob/$main/$file"
    done
  fi
}
