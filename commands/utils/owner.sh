source "$FUZZYHUB_DIR/commands/utils/remote-url.sh"

__fh-begins-with() {
  [[ $2 == $1* ]]
}

__fh-owner() {
  local repoUrl=$(__fh-remote-url)

  if __fh-begins-with "https://" "$repoUrl"; then
    echo "$repoUrl" | cut -d '/' -f 4
  elif __fh-begins-with "git@" "$repoUrl"; then
    echo "$repoUrl" | cut -d ':' -f 2 | xargs dirname
  fi
}
