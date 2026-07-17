# Workstation prompt = server base + local overrides.
# Edit prompt internals in server.zsh (the shared base); keep ONLY differences here.
source "${0:a:h}/server.zsh"

# Different dir accent so the PC never looks like one of the boxes
# (server base uses 31 / teal-blue; 76 = green).
typeset -g POWERLEVEL9K_DIR_FOREGROUND=76

# Drop the ip/bandwidth segment — that's server-watching info, noise locally.
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#ip})
