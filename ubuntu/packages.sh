#!/usr/bin/env bash
set -euo pipefail

sudo apt update

sudo apt install -y \
  git \
  curl \
  zsh \
  fzf \
  ripgrep \
  bat \
  fd-find \
  jq \
  btop \
  git-delta \
  entr \
  tmux

# On Ubuntu, bat installs as 'batcat' and fd as 'fdfind' (name conflicts).
# Symlink both to ~/.local/bin so aliases and scripts work uniformly.
mkdir -p "$HOME/.local/bin"
if [[ ! -e "$HOME/.local/bin/bat" ]]; then
  ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
fi
if [[ ! -e "$HOME/.local/bin/fd" ]]; then
  ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# Ubuntu's apt zoxide package is outdated. Install from the official upstream installer.
# Installs the latest version to ~/.local/bin/zoxide.
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
