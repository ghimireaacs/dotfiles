# Powerlevel10k profile selector
# Chooses prompt profile based on execution context

P10K_DIR="$HOME/zsh/p10k"

is_server=false

# No graphical session
[[ -z "$WAYLAND_DISPLAY" && -z "$DISPLAY" ]] && is_server=true

# WSL is the PC — workstation, even though it can look headless
grep -qi microsoft /proc/version 2>/dev/null && is_server=false

# SSH session always wins — a remote box is a server no matter what
[[ -n "$SSH_CONNECTION" ]] && is_server=true

if $is_server; then
  source "$P10K_DIR/server.zsh"
elif [[ -f "$P10K_DIR/workstation.zsh" ]]; then
  source "$P10K_DIR/workstation.zsh"
else
  source "$P10K_DIR/server.zsh"
fi
