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

_beginsWith() {
  [[ $2 == $1* ]]
}

_repository_owner() {
  local repoUrl=$(__fh-get_remote_url)

  if _beginsWith "https://" "$repoUrl"; then
    echo "$repoUrl" | cut -d '/' -f 4
  elif _beginsWith "git@" "$repoUrl"; then
    echo "$repoUrl" | cut -d ':' -f 2 | xargs dirname
  fi
}

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

_extract_domain() {
  local repoUrl=$(__fh-get_remote_url)

  if [[ "$repoUrl" == https://* ]]; then
    echo "$repoUrl" | cut -d '/' -f 3
  elif [[ "$repoUrl" == git@* ]]; then
    echo "$repoUrl" | cut -d '@' -f 2 | cut -d ':' -f 1
  fi
}

__fh-list-pr() {
  name=$(basename $(git remote get-url origin) .git)
  owner=$(_repository_owner)
  git_url=$(git remote get-url origin)
  domain="$(_extract_domain)"

  QUERY='
    query($name: String!, $owner: String!, $endCursor: String) {
      repository(owner: $owner, name: $name) {
        pullRequests(first: 100, after: $endCursor, states: OPEN, orderBy: { field: UPDATED_AT, direction: DESC }) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            title
            author {
              login
            }
            headRefName
          }
        }
      }
    }
  '

  GH_HOST=$domain gh api graphql --paginate -F owner=$owner -F name=$name -f query="${QUERY}" \
    --jq ".data.repository.pullRequests.nodes.[] | [.number, .author.login, .headRefName, .title] | @tsv" \
    | awk '{
        numberColor="\033[1;33m"  # Yellow
        loginColor="\033[1;34m"   # Blue
        branchColor="\033[1;35m"  # Magenta
        resetColor="\033[0m"

        printf numberColor "%-4s" resetColor " " loginColor "%-18s" resetColor " " branchColor "%-20s" resetColor " ", $1, $2=substr($2, 1, 18), $3=substr($3, 1, 20)
        $1=""
        $2=""
        $3=""
        print $0
    }'
}

__fh-pr() {
  if [[ -z $1 ]]; then
    echo "Usage: fh pr <option>"
    echo ""
    echo "Options:"
    echo "  checkout   - Check out the pull request"
    echo "  view       - View the pull request in the browser"
    exit 1
  fi

  local url=$(__fh-get_remote_url)

  local selected=$(__fh-list-pr | fzf -m --ansi)

  if [[ -z $selected ]]; then
    echo "No PR selected"
    exit 1
  fi

  local pr_id=$(echo $selected | awk 'END {print $1}')

  if [[ $1 == "checkout" ]]; then
    gh pr checkout $pr_id
  fi

  if [[ $1 == "view" ]]; then
    open "$url/pull/$pr_id"
  fi
}

