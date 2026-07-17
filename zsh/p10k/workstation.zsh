# Workstation prompt — the PC's own look: lean, transparent, catppuccin mocha.
# Servers keep the boxed powerline style. This file sources server.zsh (the
# shared base — all segment logic lives there) and restyles it on top.
# Never regenerate this file with `p10k configure`; re-wizard server.zsh instead.
source "${0:a:h}/server.zsh"

# ── Classic → lean (official p10k style transform) ──────────────────────────
# No grey boxes, no powerline arrows, no ▓▒░ fades, no ╭─╰─ frame.
typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no box padding
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # space between segments
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no powerline arrows
typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${P9K_VISUAL_IDENTIFIER}'
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_SUFFIX=

# ── Layout: info on line 1, type behind a bare ❯ on line 2 ──────────────────
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs newline prompt_char)
# Same informative right side as the base, minus ip — that's server-watching noise.
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#ip})

# ── Catppuccin Mocha accents (matches the tmux theme; truecolor, PC-only) ───
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND='#f5c2e7'                   # pink
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#89b4fa'                       # blue
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#b4befe'                # lavender (bold via base)
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#6c7086'             # overlay0
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#a6e3a1'                 # green
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#f9e2af'              # yellow
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR='#a6e3a1'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#a6e3a1'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#f38ba8'              # red
typeset -g POWERLEVEL9K_STATUS_ERROR_{SIGNAL,PIPE}_FOREGROUND='#f38ba8'
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#f9e2af'
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#94e2d5'           # teal
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#94e2d5'
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#fab387'                   # peach (root/ssh only)
