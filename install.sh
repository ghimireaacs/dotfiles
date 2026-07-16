#!/bin/zsh
#
# Userland bootstrap for shell environment.
#
# This script is responsible for establishing a consistent Zsh-based
# user environment across systems. It is intentionally OS-agnostic.
#
# Scope:
# - Oh My Zsh installation
# - Powerlevel10k theme installation
# - Zsh plugin installation
# - Symlinking shell-related dotfiles
# - Setting Zsh as the default login shell
#
# System package installation is handled elsewhere.

set -euo pipefail

DOTFILES_DIR=${0:a:h}

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
THEMES_DIR="$ZSH_CUSTOM/themes"
PLUGINS_DIR="$ZSH_CUSTOM/plugins"

create_symlink() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      return
    fi
    mv -f "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
}

echo "Setting up Zsh environment"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

mkdir -p "$THEMES_DIR" "$PLUGINS_DIR"

P10K_DIR="$THEMES_DIR/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

[[ -d "$PLUGINS_DIR/zsh-autosuggestions" ]] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"

[[ -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGINS_DIR/zsh-syntax-highlighting"

create_symlink "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$DOTFILES_DIR/zsh"       "$HOME/zsh"
create_symlink "$DOTFILES_DIR/cbin"      "$HOME/cbin"
create_symlink "$DOTFILES_DIR/tmux"      "$HOME/.config/tmux"

[[ -d "$HOME/.tmux/plugins/tpm" ]] || \
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

if [[ "$SHELL" != *"/zsh" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    chsh -s "$(which zsh)"
  else
    sudo chsh -s "$(which zsh)" "$USER"
  fi
fi

echo "Zsh setup complete. Log out and log back in to apply changes."
