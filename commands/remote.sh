#!/usr/bin/env bash
set -e

source "$FUZZYHUB_DIR/commands/utils/owner.sh"
source "$FUZZYHUB_DIR/commands/utils/remote-url.sh"

__fh-list-forks() {
  name=$(basename $(__fh-remote-url) .git)
  owner=$(__fh-owner)

  gh api graphql --paginate -F owner=$owner -F name=$name -f query='
    query($name: String!, $owner: String!, $endCursor: String) {
      repository(owner: $owner, name: $name) {
        forks(first: 100, after: $endCursor) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            owner {
              login
            }
            url
          }
        }
      }
    }
  ' \
  --jq ".data.repository.forks.nodes[] | [.owner.login, .url ] | @tsv" \
  | awk '{
      name="\033[1;34m"   # Blue
      url="\033[1;35m"  # Magenta
      reset="\033[0m"
  }
  {
      printf name "%-18s" reset " " url "%s" reset "\n", $1, $2
  }'
}

__fh-format-remote-url() {
  local url=$(git config --get remote.origin.url)
  local https_url="$1.git"

  if [[ "$url" == "git@"* ]]; then
    local ssh_url=$(echo $https_url | sed -E 's|https://([^/]+)/([^/]+)/([^/]+)\.git|git@\1:\2/\3.git|')
    echo "$ssh_url"
  else
    echo "$https_url"
  fi
}

__fh-remote-add() {
  local owner=$(__fh-owner)

  local selection=$(__fh-list-forks | fzf -m --ansi)

  if [[ -z ${selection} ]]; then
    echo "No remote selected"
    exit 1
  fi

  while IFS=' ' read -r name url; do
    # Check if remote already exists
    if git remote get-url "$name" &> /dev/null; then
      echo "Skipping remote $name"
      continue
    fi

    local formatted_url=$(__fh-format-remote-url "$url")
    echo "Adding remote: $name $formatted_url"
    git remote add "$name" "$formatted_url"
  done <<< "$selection"
}

__fh-remote-delete() {
  local selection=$(git remote -v | awk '{
    name="\033[1;34m"   # Blue
    url="\033[1;35m"  # Magenta
    reset="\033[0m"
  }
  {
      printf name "%-18s" reset " " url "%s" reset "\n", $1, $2
  }' | uniq | fzf -m --ansi)

  if [[ -z ${selection} ]]; then
    echo "No remote selected"
    exit 1
  fi

  while IFS=' ' read -r name url; do
    echo "Deleting remote $name $url"
    git remote remove "$name"
  done <<< "$selection"
}

__fh-remote() {
  if [[ $1 == "add" ]]; then
    __fh-remote-add
  elif [[ $1 == "delete" ]]; then
    __fh-remote-delete
  else
    echo "Usage: fh remote <option>"
    echo ""
    echo "Options:"
    echo "  add        - Add a forked repository as remote"
    echo "  delete     - Delete remote"
    exit 1
  fi
}
