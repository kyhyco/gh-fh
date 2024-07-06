__fh-remote-url() {
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
