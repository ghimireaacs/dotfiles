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
  zoxide \
  entr \
  tmux

# fastfetch only entered the archive in trixie — skip on older releases rather
# than aborting the whole bootstrap under `set -e`.
if apt-cache show fastfetch >/dev/null 2>&1; then
  sudo apt install -y fastfetch
else
  echo "NOTE: no fastfetch package on this release, skipping"
fi

# fastfetch draws its image logo through ImageMagick, which it dlopen()s at
# runtime rather than declaring as a dependency — without this the logo silently
# degrades to ASCII art. Package name tracks the ImageMagick major/quantum, so
# take whichever this release actually ships.
for pkg in libmagickcore-7.q16hdri-10 libmagickcore-7.q16-10 libmagickcore-6.q16-7 libmagickcore-6.q16-6; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    sudo apt install -y "$pkg"
    break
  fi
done

# On Debian, bat installs as 'batcat' and fd as 'fdfind' (name conflicts).
# Symlink both to ~/.local/bin so aliases and scripts work uniformly.
mkdir -p "$HOME/.local/bin"
if [[ ! -e "$HOME/.local/bin/bat" ]]; then
  ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
fi
if [[ ! -e "$HOME/.local/bin/fd" ]]; then
  ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
