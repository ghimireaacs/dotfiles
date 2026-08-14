#!/usr/bin/env sh
# Standalone fastfetch setup — config + logo image, nothing else.
# Same script works alone: clone the repo, run this, get a working fastfetch.
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="$HOME/.config/fastfetch"

command -v fastfetch >/dev/null 2>&1 || echo "WARNING: fastfetch not found on PATH — config will just sit there until it's installed"

mkdir -p "$CONF"

link() {
  src="$1"
  dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak"
  fi
  ln -s "$src" "$dst"
}

link "$DIR/config.jsonc" "$CONF/config.jsonc"
link "$DIR/logo.png"     "$CONF/logo.png"

# fastfetch caches the encoded image under ~/.cache/fastfetch/images, keyed by
# source path and pixel size — NOT by content or mtime. Swap logo.png for another
# image of the same dimensions and it will happily keep drawing the old one.
# Deploying a logo means invalidating that cache.
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch/images"

# The image logo is decoded through ImageMagick, which fastfetch dlopen()s at
# runtime — it is NOT a package dependency, so a stock install silently falls
# back to ASCII art with only `fastfetch --show-errors` telling you why.
# packages.sh installs it; this check catches boxes set up some other way.
if [ "$(uname)" != "Darwin" ] && command -v ldconfig >/dev/null 2>&1; then
  if ! ldconfig -p 2>/dev/null | grep -q libMagickCore; then
    echo "NOTE: no ImageMagick runtime library found — the logo will fall back to ASCII art."
    echo "      Debian/Ubuntu: sudo apt install libmagickcore-7.q16hdri-10"
    echo "      Arch:          sudo pacman -S imagemagick"
  fi
fi

echo "fastfetch config ready. Test it: fastfetch"
