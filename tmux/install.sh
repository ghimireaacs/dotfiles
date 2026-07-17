#!/usr/bin/env sh
# Standalone tmux setup — config + plugins, nothing else.
# For boxes that only get tmux (Kali, jump hosts): clone the repo,
# run this, ignore the rest. No zsh layer, no PATH edits.
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="$HOME/.config/tmux"

command -v tmux >/dev/null 2>&1 || { echo "tmux not installed (apt install tmux)"; exit 1; }

mkdir -p "$HOME/.config"
if [ -L "$CONF" ]; then
  rm "$CONF"
elif [ -e "$CONF" ]; then
  mv "$CONF" "$CONF.bak"
fi
ln -s "$DIR" "$CONF"

[ -d "$HOME/.tmux/plugins/tpm" ] || \
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

echo "tmux ready. Start: tmux   Layouts: ~/.config/tmux/t"
