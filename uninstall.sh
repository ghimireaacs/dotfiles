#!/bin/zsh
#
# Userland teardown for shell environment.
#
# This script reverses the changes made by install.sh.
# It removes symlinks created by this repository and
# optionally restores previous backups.
#
# Scope:
# - Remove symlinked dotfiles managed by this repo
# - Restore backed-up files if present
# - Does NOT remove Oh My Zsh, plugins, or system packages
#
# This script is safe to run multiple times.

set -euo pipefail

DOTFILES_DIR=${0:a:h}

restore_or_remove() {
  local target="$1"

  if [[ -L "$target" ]]; then
    local backup="${target}.bak"
    rm "$target"
    if [[ -e "$backup" ]]; then
      mv "$backup" "$target"
    fi
  fi
}

echo "Reverting Zsh environment changes"

restore_or_remove "$HOME/.zshrc"
restore_or_remove "$HOME/.p10k.zsh"
restore_or_remove "$HOME/zsh"
restore_or_remove "$HOME/cbin"
restore_or_remove "$HOME/.config/tmux"

echo "Uninstall complete."

echo ""
echo "Notes:"
echo "- Oh My Zsh and plugins were left untouched"
echo "- System packages were not modified"
echo "- Log out and log back in if shell behavior was changed"
