#!/usr/bin/env bash
set -e

__fh-push() {
  local remote
  local rest

  # remote is a git push option
  if [[ $1 = -* ]]; then
    remote="origin"
    rest=( "$@" )

  # no argument supplied
  elif [[ -z $1 ]]; then
    remote="origin"
    rest=( "$@" )

  # remote name provided
  else
    remote=$1;shift
    rest=( "$@" )
  fi

  git push -u $remote $(git symbolic-ref --short -q HEAD) "${rest[@]}"
}
