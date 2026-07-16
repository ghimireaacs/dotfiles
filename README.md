# dotfiles

Opinionated dotfiles and shell bootstrap for my servers and workstations. Single source of truth for Zsh, tmux, aliases, and custom scripts — shared unchanged across all machines.

---

## What's included

| Layer | Contents |
|---|---|
| `zsh/aliases/` | General, git, docker, function-based aliases |
| `zsh/exports/` | PATH, NVM, and other environment exports |
| `zsh/functions/` | Custom Zsh functions |
| `zsh/p10k/` | Powerlevel10k profiles (server / workstation / default) |
| `tmux/` | tmux config + TPM plugin manager |
| `cbin/` | Custom helper scripts (`dockstat`, `dockerTCP`) |

---

## OS support

| OS | Package script | Notes |
|---|---|---|
| macOS | `macos/packages.sh` | Homebrew required; `bat` and `eza` included natively |
| Arch Linux | `arch/packages.sh` | Full toolset via pacman |
| Debian | `debian/packages.sh` | apt + batcat symlink |
| Ubuntu | `ubuntu/packages.sh` | apt + batcat symlink + zoxide from upstream |

### Why macOS gets its own script

Homebrew is assumed to be pre-installed. Unlike Debian/Ubuntu, `bat` on macOS installs as `bat` (no `batcat` conflict), so no symlink is needed. `eza` is available directly via brew, same as Arch.

### Why Ubuntu gets its own script

Two packages behave differently on Ubuntu vs Debian:

- **bat** — On both Debian and Ubuntu, `apt install bat` installs the binary as `batcat` (to avoid conflict with another `bat` package). The scripts create `~/.local/bin/bat → /usr/bin/batcat` so everything works uniformly.
- **zoxide** — Ubuntu's apt repo ships an outdated version. The Ubuntu script installs zoxide directly from the official upstream installer to get the current release.

---

## Installation

### 1. Clone

```bash
git clone https://github.com/ghimireaacs/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run bootstrap

```bash
bash bootstrap.sh
```

The script auto-detects your OS and runs the correct package installer, then runs the shell setup.

What it does:
- Installs system packages for your OS
- Installs Oh My Zsh
- Installs Powerlevel10k theme
- Installs zsh-autosuggestions and zsh-syntax-highlighting
- Symlinks `.zshrc`, `.p10k.zsh`, `zsh/`, `tmux/`, and `cbin/`
- Sets Zsh as your default login shell

### 3. Log out and back in

Required for the shell change to take effect.

### 4. Install tmux plugins

On first tmux launch:

```
Prefix + I
```

(Prefix is `Ctrl + Space`)

---

## Packages installed

| Package | Purpose | macOS | Arch | Debian | Ubuntu |
|---|---|---|---|---|---|
| git | Version control | brew | pacman | apt | apt |
| curl | HTTP client | brew | pacman | apt | apt |
| zsh | Shell | brew | pacman | apt | apt |
| fzf | Fuzzy finder | brew | pacman | apt | apt |
| ripgrep | Fast grep | brew | pacman | apt | apt |
| bat | Syntax-highlighted cat | brew | pacman | apt (→ batcat) | apt (→ batcat) |
| eza | Modern ls | brew | pacman | — | — |
| zoxide | Smarter cd | brew | pacman | apt | upstream |
| entr | Run on file change | brew | pacman | apt | apt |
| tmux | Terminal multiplexer | brew | pacman | apt | apt |

---

## Shell setup

- **Framework:** Oh My Zsh
- **Theme:** Powerlevel10k (wizard runs on first login, re-run with `p10k configure`)
- **Plugins:** zsh-autosuggestions, zsh-syntax-highlighting, fzf
- **cd:** aliased to `z` (zoxide)
- **ls/ll/la:** aliased to `eza` variants

---

## Re-running safely

All scripts are idempotent:
- Existing dotfiles are backed up as `.bak` before symlinking
- Already-installed tools are skipped
- Safe to re-run on existing systems

---

## What this repo does not manage

- Desktop environments or GUI applications
- System services
- OS-level configuration
- Anything that requires root beyond package installs

---

## License

Personal use. Adapt freely.
