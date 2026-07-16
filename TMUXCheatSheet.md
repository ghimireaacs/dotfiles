**Prefix:** `Ctrl` + `Space`

Everything not listed here is stock tmux — muscle memory transfers to any bare box (Kali targets, servers without dotfiles).

#### Core Commands

| Keystroke                   | Action                                      |
| --------------------------- | ------------------------------------------- |
| **General**                 |                                             |
| `Prefix` + `r`              | Reload tmux config                          |
| `Prefix` + `d`              | Detach from current session                 |
| `Prefix` + `?`              | List all keybindings                        |
| **Sessions**                |                                             |
| `Prefix` + `o`              | Open session manager (`sessionx`)           |
| `Prefix` + `s`              | Show interactive session list               |
| `Prefix` + `(` / `)`        | Switch to previous/next session             |
| `Prefix` + `$`              | Rename current session                      |
| **Windows**                 | _(like browser tabs)_                       |
| `Prefix` + `c`              | Create a new window                         |
| `Prefix` + `,`              | Rename current window                       |
| `Prefix` + `w`              | Show interactive window list                |
| `Prefix` + `&`              | Kill current window (asks y/n)              |
| `Prefix` + `n`              | Go to next window                           |
| `Prefix` + `0-9`            | Go to window by number                      |
| `Prefix` + `Ctrl`+`h` / `l` | Go to previous/next window                  |
| `Prefix` + `Ctrl`+`a`       | Toggle between last two windows             |
| **Panes**                   | _(splits within a window)_                  |
| `Prefix` + `\|`             | Split vertically (left/right)               |
| `Prefix` + `-`              | Split horizontally (top/bottom)             |
| `Prefix` + `h`/`j`/`k`/`l`  | Navigate panes using Vim keys               |
| `Prefix` + `H`/`J`/`K`/`L`  | Resize panes (hold `Prefix` + tap)          |
| `Prefix` + `z`              | Zoom/unzoom current pane                    |
| `Prefix` + `x`              | Kill current pane (asks y/n)                |
| `Prefix` + `{` / `}`        | Move current pane left/right                |
| `Prefix` + `*`              | Toggle sync: type into ALL panes at once    |

> `Prefix` + `p` is NOT previous-window here — floax took it (see below).
> Use `Ctrl+h` or `Ctrl+a` (after prefix) instead.

---

#### Plugins & Copy Mode

| Keystroke        | Action                                            |
| ---------------- | ------------------------------------------------- |
| `Prefix` + `I`   | Install plugins (first launch on a new machine)   |
| `Prefix` + `[`   | Enter copy mode (scroll with vi keys / `Ctrl+u`)  |
| `v`, then `y`    | In copy mode: start selection, then yank (copy)   |
| `Prefix` + `]`   | Paste from tmux buffer                            |
| `Prefix` + `p`   | Toggle floating terminal (`floax`)                |
| `Prefix` + `u`   | Fuzzy-pick a URL from pane output (`fzf-url`)     |
| `Prefix` + `t`   | Hint-jump to copy text on screen (`tmux-thumbs`)  |

---

#### Task Layouts (`t`)

Repeatable pre-arranged sessions. Backed by `~/.config/tmux/t` (ships in the
tmux dir — stock tmux, no plugins, so it works on a vanilla Kali box that only
has the tmux config ported).

| Keystroke / Command | Action                                             |
| ------------------- | -------------------------------------------------- |
| `Prefix` + `T`      | Pop a menu to build/switch to a layout             |
| `t`                 | (shell) List running sessions + known layouts      |
| `t nmap`            | (shell) Build/attach `nmap` session, 3-pane recon  |
| `t recon`           | (shell) Build/attach `recon` session, main + log   |

Already running? `t <name>` and the menu just jump to it. Add a layout by
editing the `case` block in `~/.config/tmux/t`.

---

#### Shell Commands

_(Run these in your terminal, outside of tmux)_

| Command             | Action                              |
| ------------------- | ----------------------------------- |
| `tmux ls`           | **List** all running tmux sessions. |
| `tmux a -t <name>`  | **Attach** to a specific session.   |
| `tmux new -s <name>`| Start a **new named** session.      |
