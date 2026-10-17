#!/usr/bin/env sh
# Apply the repository's Noctalia settings, keeping earlier versions as backups.
#
# COPY, not symlink: noctalia rewrites settings.toml live (theme picks,
# wallpaper choice, panel state), so symlinking it into the repo would mean
# every click in the app leaves the git tree dirty. Edit the repo copy and
# rerun this to redeploy; if you like something you changed in the app,
# copy it back into the repo by hand.
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"
STATE="$HOME/.local/state/noctalia"

. "$DIR/../lib/files.sh"
copy_file "$DIR/settings.toml" "$STATE/settings.toml"

echo "Noctalia settings applied. Earlier settings are kept in numbered .bak files."
echo "Restart noctalia (or niri) to pick them up."
