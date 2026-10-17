#!/bin/zsh
# Remove links owned by this checkout and restore the latest available backups.

set -euo pipefail

DOTFILES_DIR=${0:a:h}

. "$DOTFILES_DIR/lib/files.sh"

echo "Removing links owned by this checkout"

restore_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
restore_link "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
restore_link "$DOTFILES_DIR/zsh" "$HOME/zsh"
restore_link "$DOTFILES_DIR/cbin" "$HOME/cbin"
restore_link "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"
restore_link "$DOTFILES_DIR/tmux/t" "$HOME/.local/bin/t"
restore_link "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
restore_link "$DOTFILES_DIR/fastfetch/logo.png" "$HOME/.config/fastfetch/logo.png"
restore_link "$DOTFILES_DIR/niri/config.kdl" "$HOME/.config/niri/config.kdl"
restore_link "$DOTFILES_DIR/niri/binds.kdl" "$HOME/.config/niri/binds.kdl"

echo "Done. Packages, plugins, copied desktop settings, Git settings and login shell were kept."
echo "See troubleshoot.md for restoring those settings or choosing an older backup."
