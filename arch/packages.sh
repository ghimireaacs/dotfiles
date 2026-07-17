#!/usr/bin/env bash
set -euo pipefail

sudo pacman -Syu --needed \
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
  entr \
  zoxide \
  tmux
