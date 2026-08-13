#!/usr/bin/env sh
# Standalone noctalia setup — seeds the shell's settings.
#
# COPY, not symlink: noctalia rewrites settings.toml live (theme picks,
# wallpaper choice, panel state), so symlinking it into the repo would mean
# every click in the app leaves the git tree dirty. Edit the repo copy and
# rerun this to redeploy; if you like something you changed in the app,
# copy it back into the repo by hand.
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
STATE="$HOME/.local/state/noctalia"

mkdir -p "$STATE"

if [ -e "$STATE/settings.toml" ]; then
  cp "$STATE/settings.toml" "$STATE/settings.toml.bak"
fi

cp "$DIR/settings.toml" "$STATE/settings.toml"

echo "noctalia settings deployed to $STATE/settings.toml (previous saved as .bak)."
echo "Restart noctalia (or niri) to pick them up."
