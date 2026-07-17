#!/usr/bin/env sh
# Nerd Font install for GUI boxes (Kali VM, etc.) — optional companion to install.sh.
# Icons render on the machine you're LOOKING at: SSH boxes don't need this
# (your local terminal's font covers them); a box whose GUI you sit at does.
set -eu

FONT_DIR="$HOME/.local/share/fonts"
BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"

command -v fc-cache >/dev/null 2>&1 || { echo "fontconfig not found — is this a GUI box?"; exit 1; }

mkdir -p "$FONT_DIR"
for f in 'MesloLGS NF Regular.ttf' 'MesloLGS NF Bold.ttf' \
         'MesloLGS NF Italic.ttf' 'MesloLGS NF Bold Italic.ttf'; do
  [ -f "$FONT_DIR/$f" ] && continue
  echo "Downloading $f"
  curl -fsSL -o "$FONT_DIR/$f" "$BASE/$(printf %s "$f" | sed 's/ /%20/g')"
done
fc-cache -f "$FONT_DIR"

echo "MesloLGS NF installed."
echo "Now select it in the terminal: qterminal -> File -> Preferences -> Appearance -> Font."
