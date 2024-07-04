#!/usr/bin/env bash
set -e

__fh-get_remote_url() {
  local url=$(git config --get remote.upstream.url)

  if [[ -z "$url" ]]; then
    url=$(git config --get remote.origin.url)
  fi

  if [[ "$url" == "git@"* ]]; then
    echo "$url" | sed -E 's|^git@([^:]+):([^/]+)/([^\.]+)(\.git)?$|https://\1/\2/\3|'
  else
    echo "${url%.git}"
  fi
}

__fh-view() {
  local url=$(__fh-get_remote_url)

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
