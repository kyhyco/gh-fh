<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./logo.png">
        <img alt="fuzzyhub-logo" src="./logo.png" width="200px">
    </picture>
</p>

# Fuzzyhub = **fzf** + **GitHub CLI**

`Fuzzyhub` is a collection of tools to super charge your git workflow.

## Installation

```bash
brew install gh fzf
gh extension install kyhyco/gh-fh
```

## Available commands

```bash
Usage: fh <option>

Options:
  checkout     - Checkout branch
  view         - View folder/files in the browser

  pr checkout  - Checkout PR branch
  pr view      - View PR in the browser

  prune        - Prune merged branches
  delete       - Delete branches

  sync         - Sync main/master branch
```

## Recommended shell aliases:

```bash
alias fh="gh fh"

alias fco="gh fh checkout"
alias fv="gh fh view"

alias pco="gh fh pr checkout"
alias pv="gh fh pr view"
```
