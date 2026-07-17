# dotfiles

Opinionated dotfiles and shell bootstrap for my servers and workstations. Single source of truth for Zsh, tmux, aliases, and helper scripts — the same repo is cloned to every machine, and everything is **symlinked**, so `git pull` *is* the deploy.

```
bootstrap.sh          OS detection → package install → shell setup
├── <os>/packages.sh  system packages (macos / arch / ubuntu / debian)
└── install.sh        Oh My Zsh, Powerlevel10k, plugins, symlinks, chsh
    └── tmux/install.sh   tmux config + TPM + plugins (also works standalone)
```

| Path | What it is |
|---|---|
| `.zshrc` | Shell entry point — sources everything below |
| `zsh/exports/` | Environment setup, one file per tool, each guarded (`nvm`, `cargo`, `go`, `gcloud`, …) — missing tools are silently skipped |
| `zsh/aliases/` | Aliases: general, git, docker, terraform |
| `zsh/functions/` | Custom Zsh functions |
| `zsh/p10k/` | Powerlevel10k profiles (auto-selected, see below) |
| `tmux/` | tmux config, plugins list, `t` layout launcher — self-contained |
| `cbin/` | Helper scripts (`dockstat`, `dockerTCP.sh`) |
| `windows/` | PowerShell profile, oh-my-posh theme, fastfetch config + installer — see below |
| `uninstall.sh` | Removes the symlinks, restores `.bak` backups |

---

## Full install

```bash
git clone https://github.com/ghimireaacs/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash bootstrap.sh
```

Detects the OS (macOS → Arch → Ubuntu → Debian), installs packages, then:

- Installs Oh My Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting
- Symlinks `.zshrc`, `.p10k.zsh`, `zsh/`, `cbin/` into `$HOME` and `tmux/` to `~/.config/tmux`
- Installs TPM and all tmux plugins (no `prefix + I` needed)
- Sets Zsh as the login shell

Log out and back in when it finishes. Everything is idempotent: existing files are backed up as `.bak` before symlinking, installed pieces are skipped, safe to re-run.

## tmux-only install

For boxes that get tmux and nothing else (Kali, jump hosts — no zsh layer, no PATH changes):

```bash
git clone https://github.com/ghimireaacs/dotfiles.git ~/dotfiles
sh ~/dotfiles/tmux/install.sh
```

Symlinks `tmux/` to `~/.config/tmux` and installs plugins. Requires `tmux` and `git` to already be on the box. Everything tmux needs lives inside `tmux/` by design — porting it means copying that one directory.

If you sit at the box's own GUI (Kali VM), also run `sh ~/dotfiles/tmux/fonts.sh` — installs MesloLGS Nerd Font for the status-bar icons, then pick it in the terminal's preferences. SSH-only boxes skip this: icons render in *your* terminal's font, not the remote's.

## Windows install

PowerShell-side of the same look — lean catppuccin oh-my-posh prompt (mirrors the WSL workstation prompt), fastfetch at startup, zoxide, Terminal-Icons, unix-ish helper functions (`Show-Help` lists them). Requires [scoop](https://scoop.sh); no admin needed.

```bat
windows\install.bat
```

(or `pwsh -File windows\install.ps1`). Installs missing tools (zoxide, fastfetch, oh-my-posh, Terminal-Icons), then **copies** — not symlinks, those need admin on Windows — the profile + theme next to `$PROFILE` and `fastfetch.jsonc` to `~\.config\fastfetch\config.jsonc`. First pre-existing profile is kept as `.bak`. After a `git pull`, rerun the installer to deploy changes; edit the repo copies, not the live ones.

## Updating a machine

```bash
cd ~/dotfiles && git pull
```

Done — symlinks pick up everything. Machine-specific lines belong in `~/.zshrc.local` (sourced last, not tracked), **never** in the repo's `.zshrc` — local edits there block the next pull.

---

## Shell

- **Framework:** Oh My Zsh, **theme:** Powerlevel10k (`p10k configure` to re-run the wizard)
- **Plugins:** zsh-autosuggestions, zsh-syntax-highlighting, fzf, git
- `cd` → zoxide, `ls`/`ll`/`la`/`tree` → eza (only where eza is installed; apt boxes keep stock `ls`)
- `delta` becomes the git pager when installed (`install.sh` sets it via `git config --global`)
- SSH sessions set the terminal title to `SSH: <hostname>` so tabs identify their box; the local machine keeps its own title

**Prompt profiles** are chosen at runtime by `.p10k.zsh` — no install-time choice:

| Condition | Profile | Look |
|---|---|---|
| SSH session, or headless (no display) | `zsh/p10k/server.zsh` | Boxed powerline frame (╭─╰─), grey segment backgrounds, ip/bandwidth segment — reads "you are on a box" |
| Local session (incl. WSL) | `zsh/p10k/workstation.zsh` | Lean: transparent, no frame, no arrows, catppuccin mocha colors, bare `❯` input line — matches the tmux theme |

`server.zsh` is the full generated config and holds all segment logic; `workstation.zsh` sources it and restyles on top. Re-running `p10k configure` should only ever regenerate `server.zsh`.

## tmux

Prefix is `Ctrl+Space`. Bindings stay **stock-compatible** on purpose (no rebinds of `c`/`x`/`,`/`w`) so muscle memory transfers to bare tmux on unfamiliar boxes. Full reference: [`TMUXCheatSheet.md`](TMUXCheatSheet.md).

- Plugins via TPM: catppuccin theme, sensible, yank, resurrect + continuum (session persistence), thumbs, fzf, fzf-url, sessionx, floax
- `t <layout>` (or `prefix T` menu) builds pre-split task sessions — `t nmap` (3-pane recon), `t recon` (main + log). Plain POSIX sh, works on stock tmux with zero plugins. Add layouts in the `case` block of `tmux/t`.
- `escape-time` is 50ms, not 0 — at 0, escape sequences split across SSH packets get misparsed into garbage text and broken mouse scrolling

---

## OS notes

| OS | Script | Why it's separate |
|---|---|---|
| macOS | `macos/packages.sh` | Homebrew assumed present; `bat` and `eza` install cleanly under their own names |
| Arch | `arch/packages.sh` | Everything via pacman, including `eza` |
| Ubuntu | `ubuntu/packages.sh` | apt's zoxide is outdated → installed from upstream; `bat`/`fd` install as `batcat`/`fdfind` → symlinked into `~/.local/bin` |
| Debian | `debian/packages.sh` | apt zoxide is fine; same `batcat`/`fdfind` symlinks. Kali lands here (`/etc/debian_version`) — but Kali should use the tmux-only install instead |

Packages everywhere: git, curl, zsh, fzf, ripgrep, bat, fd, jq, btop, delta, zoxide, entr, tmux (+ eza on macOS/Arch).

---

## Not managed here

Desktop environments, GUI apps, system services, OS configuration — anything needing root beyond package installs.

## License

Personal use. Adapt freely.
