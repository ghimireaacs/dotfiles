#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

brew install \
  git \
  curl \
  zsh \
  fzf \
  ripgrep \
  bat \
  eza \
  fd \
  jq \
  btop \
  git-delta \
  zoxide \
  entr \
  tmux
