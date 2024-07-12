<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./logo.png">
        <img alt="fuzzyhub-logo" src="./logo.png" width="200px">
    </picture>
</p>

<p align="center">
    <a href="https://github.com/kyhyco/gh-fh/releases/latest">
        <img alt="Latest release" src="https://img.shields.io/github/v/release/kyhyco/gh-fh?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41&include_prerelease&sort=semver&_cache_bust=" />
    </a>
</p>

# Fuzzyhub

`Fuzzyhub` is a collection of tools to super charge your git workflow.

Built with [fzf](https://github.com/junegunn/fzf) and [GitHub Graphql API](https://docs.github.com/en/graphql/guides).

## Installation

```bash
brew install gh fzf bat
gh extension install kyhyco/gh-fh
```

### Set shell alias
```bash
alias fh="gh fh"
```

## Available commands

```bash
Usage: fh <option>

Options:
  checkout       - Checkout branch
  view           - View folder/files in the browser

  pr checkout    - Checkout PR branch
  pr view        - View PR in the browser

  prune          - Prune merged branches
  push           - Push to origin by default
  delete         - Delete branches
  sync           - Sync main/master branch

  remote add     - Add forked repositories to remote
  remote delete  - Delete remote

  version        - Print version
```

## Recommended shell aliases:

```bash
alias fh="gh fh"

alias fco="gh fh checkout"
alias fv="gh fh view"

alias pco="gh fh pr checkout"
alias pv="gh fh pr view"
```
