#!/usr/bin/env sh
# Standalone tmux setup — config + plugins, nothing else.
# For boxes that only get tmux (Kali, jump hosts): clone the repo,
# run this from the complete checkout. No Zsh setup or shell-file edits.
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="$HOME/.config/tmux"

command -v tmux >/dev/null 2>&1 || { echo "tmux not installed (apt install tmux)"; exit 1; }

. "$DIR/../lib/files.sh"
link_file "$DIR" "$CONF"
link_file "$DIR/t" "$HOME/.local/bin/t"

[ -d "$HOME/.tmux/plugins/tpm" ] || \
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

# tmux-yank needs a clipboard tool, or mouse-copy never reaches the system clipboard
if [ -n "${WAYLAND_DISPLAY:-}" ] && ! command -v wl-copy >/dev/null 2>&1; then
  echo "WARNING: no wl-copy — copy won't reach the clipboard (apt install wl-clipboard)"
elif [ -n "${DISPLAY:-}" ] && ! command -v xclip >/dev/null 2>&1 && ! command -v xsel >/dev/null 2>&1; then
  echo "WARNING: no xclip/xsel — copy won't reach the clipboard (apt install xclip)"
fi

echo "For the t command, add ~/.local/bin to PATH if your shell does not already do so."
echo "tmux ready. Start: tmux   Layouts: ~/.config/tmux/t"
