# Herdr config (ported from ../tmux)

Same muscle memory as `tmux/tmux.conf`: **prefix is Ctrl+Space**, then the same key.
Herdr naming: tmux *session* = **space**, *window* = **tab**, *pane* = **pane**.
Terminals live in herdr-core (`hc`) on the server, so closing or minimizing the
Herdr window is a detach. Closing a *pane or tab* kills its program — that's `kill-pane`, not detach.

| Prefix + | Does | tmux origin |
|---|---|---|
| `\|` / `-` | split right / down | `bind \|`, `bind -` |
| `h j k l` | focus pane | same |
| `H J K L` | swap pane (no resize in Herdr — drag the divider) | resize |
| `C-h` / `C-l` | prev / next tab, repeatable 500 ms | prev/next window |
| `c` `n` `p` `,` `&` `x` `z` | new / next / prev / rename / close tab, close pane, zoom | stock |
| `1`–`9`, `0` | tab 1–9, 10 | base-index 1 |
| `(` / `)` | prev / next space | switch-client -p/-n |
| `s` / `o` | command palette (jump to space/tab) | choose-session / sessionx |
| `S` / `$` | new / rename space | new-session / rename |
| `[` | search scrollback | copy-mode |
| `d` | minimize window (= detach) | detach |
| `?` | show all bindings | list-keys |
| `Ctrl+Space` | send a literal Ctrl+Space | send-prefix |

Without a prefix, Herdr defaults still work: `alt-h/j/k/l` focus, `ctrl-1..9` tabs,
`alt-1..9` spaces, `ctrl-shift-c/v` copy/paste, `ctrl-shift-f` search.

Not ported (no Herdr equivalent): `C-a` last-window, `*` synchronize-panes, `T` layouts menu,
floax, thumbs, fzf-url, resurrect/continuum (not needed: the core keeps everything).

## Install (Windows)
Clone dotfiles, then `powershell -ExecutionPolicy Bypass -File herdr\install.ps1`.
Copies `keys.json`, `mods/ghost-prefix/`, `themes/catppuccin-mocha.json` into
`%USERPROFILE%\.config\herdr-app` and sets the theme. Backs up first. Applies live.
Escape hatch if keys break: `ctrl-alt-shift-escape` resets layout + keys.
