#!/bin/zsh
# Install the shell configuration, tmux plugins, and fastfetch artwork.

set -euo pipefail

DOTFILES_DIR=${0:a:h}

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
THEMES_DIR="$ZSH_CUSTOM/themes"
PLUGINS_DIR="$ZSH_CUSTOM/plugins"

. "$DOTFILES_DIR/lib/files.sh"

if [[ $# -ne 0 ]]; then
  echo "Usage: zsh install.sh (desktop settings: sh niri/install.sh; sh noctalia/install.sh)" >&2
  exit 1
fi

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

link_file "$DOTFILES_DIR/.zshrc"    "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/zsh"       "$HOME/zsh"
link_file "$DOTFILES_DIR/cbin"      "$HOME/cbin"

# tmux: symlink config + TPM + plugins (same script works standalone)
sh "$DOTFILES_DIR/tmux/install.sh"

# fastfetch: config + logo, every machine including servers (same script works standalone)
sh "$DOTFILES_DIR/fastfetch/install.sh"

# Desktop settings are applied separately to preserve live preferences.
# Use delta for Git output when installed.
if command -v delta >/dev/null 2>&1; then
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
fi

if [[ "$SHELL" != *"/zsh" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    chsh -s "$(which zsh)"
  else
    sudo chsh -s "$(which zsh)" "$USER"
  fi
fi

echo "Zsh setup complete. Log out and log back in to apply changes."
