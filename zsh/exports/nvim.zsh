# Neovim tarball install (not covered by any packages.sh)
[[ -d /opt/nvim-linux-x86_64/bin ]] && export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
command -v nvim &>/dev/null && export EDITOR=nvim
