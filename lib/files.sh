# Shared file handling for the installers. Compatible with sh and zsh.

backup_file() (
  if [ -n "${ZSH_VERSION:-}" ]; then setopt nonomatch; fi
  target=$1
  [ -e "$target" ] || [ -L "$target" ] || exit 0
  backup="$target.bak"
  number=0
  for candidate in "$target".bak.*; do
    [ -e "$candidate" ] || [ -L "$candidate" ] || continue
    suffix=${candidate##*.}
    case "$suffix" in ''|*[!0-9]*) continue ;; esac
    if [ "$suffix" -gt "$number" ]; then number=$suffix; fi
  done
  if [ -e "$backup" ] || [ -L "$backup" ] || [ "$number" -gt 0 ]; then
    backup="$target.bak.$((number + 1))"
  fi
  mv "$target" "$backup"
  printf 'Saved %s\n' "$backup"
)

link_file() (
  source_file=$1
  target=$2
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_file" ]; then
    exit 0
  fi
  mkdir -p "$(dirname "$target")"
  backup_file "$target"
  ln -s "$source_file" "$target"
)

copy_file() (
  source_file=$1
  target=$2
  if [ ! -L "$target" ] && [ -f "$target" ] && cmp -s "$source_file" "$target"; then
    exit 0
  fi
  mkdir -p "$(dirname "$target")"
  backup_file "$target"
  cp "$source_file" "$target"
)

restore_link() (
  if [ -n "${ZSH_VERSION:-}" ]; then setopt nonomatch; fi
  source_file=$1
  target=$2
  [ -L "$target" ] || exit 0
  if [ "$(readlink "$target")" != "$source_file" ]; then
    printf 'Leaving unrelated link: %s\n' "$target"
    exit 0
  fi
  rm "$target"
  backup="$target.bak"
  newest=0
  for candidate in "$target".bak.*; do
    [ -e "$candidate" ] || [ -L "$candidate" ] || continue
    number=${candidate##*.}
    case "$number" in ''|*[!0-9]*) continue ;; esac
    if [ "$number" -gt "$newest" ]; then
      newest=$number
      backup=$candidate
    fi
  done
  if [ -e "$backup" ] || [ -L "$backup" ]; then
    mv "$backup" "$target"
    printf 'Restored %s\n' "$target"
  fi
)
