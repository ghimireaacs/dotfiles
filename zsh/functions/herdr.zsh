# herdr-core (hc) helpers: attach to long-lived terminals by nickname.
# Works alongside tmux; touches nothing tmux-related. Detach with Ctrl+\.
#
#   cl            attach to Claude Code      cx            attach to Codex
#   ha <nick|t7>  attach to anything         hn <t7> <nick> give a terminal a nickname
#   hl            list live terminals (with nicknames and what they're running)
#
# Lookup order: nickname label (set by hn), then hc --name, then auto-detect
# by the running program (claude / codex), so it works with tabs opened from
# Herdr's + menu without any setup.

(( $+commands[hc] )) || return 0

# Print addresses of live terminals matching $1 (nickname, name, or program).
_hc_find() {
  local want=$1
  hc ls --json 2>/dev/null | jq -r '.terminals[].address' | while read -r t; do
    hc get "$t" --json 2>/dev/null | jq -r --arg w "$want" '
      select(.state == "live")
      | select(
          (.labels.nick // "") == $w
          or (.name // "") == $w
          or (if $w == "claude" then (.agent // "") == "claude-code" else (.agent // "") == $w end)
          or ([(.foreground.argv // [])[] | split("/") | last] | index($w))
        )
      | .address'
  done
}

ha() {
  [[ -z $1 ]] && { hc; return; }               # no arg: hc's own picker
  [[ $1 == t<->* || $1 == */* ]] && { hc attach "$1"; return; }
  local -a hits=("${(@f)$(_hc_find "$1")}")
  hits=(${hits:#})
  case ${#hits} in
    0) echo "ha: no live terminal matches '$1' (hl to list)" >&2; return 1 ;;
    1) hc attach "${hits[1]}" ;;
    *) echo "ha: several match '$1':"
       local t; for t in $hits; do printf '  %s  %s\n' "$t" "$(hc get "$t" --json | jq -r '.labels.where // .cwd')"; done
       local pick; read -r "pick?attach which? " && [[ -n $pick ]] && hc attach "$pick" ;;
  esac
}

hn() {
  [[ $# -eq 2 ]] || { echo "usage: hn <t7> <nickname>   (hn <t7> '' clears)" >&2; return 1; }
  hc label "$1" "nick=$2" >/dev/null && echo "$1 -> ${2:-(cleared)}"
}

hl() {
  hc ls --json | jq -r '.terminals[].address' | while read -r t; do
    hc get "$t" --json | jq -r '[.address, (.labels.nick // .name // "-"),
      ((.foreground.argv // .argv) | map(split("/") | last) | join(" ") | .[0:40]),
      (.labels.where // .cwd)] | @tsv'
  done | column -t -s $'\t'
}

cl() { ha claude; }
cx() { ha codex; }
