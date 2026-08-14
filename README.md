# dotfiles

Opinionated dotfiles and shell bootstrap for my servers and workstations. Single source of truth for Zsh, tmux, aliases, and helper scripts — the same repo is cloned to every machine, and everything is **symlinked**, so `git pull` *is* the deploy.

```
bootstrap.sh          OS detection → package install → shell setup
├── <os>/packages.sh  system packages (macos / arch / ubuntu / debian)
└── install.sh        Oh My Zsh, Powerlevel10k, plugins, symlinks, chsh
    ├── tmux/install.sh      tmux config + TPM + plugins (also works standalone)
    ├── fastfetch/install.sh fastfetch config + logo image (also works standalone)
    ├── niri/install.sh      niri config + binds, only if niri is on PATH (also works standalone)
    └── noctalia/install.sh  noctalia settings seed, only if niri is on PATH (also works standalone)
```

| Path | What it is |
|---|---|
| `.zshrc` | Shell entry point — sources everything below |
| `zsh/exports/` | Environment setup, one file per tool, each guarded (`nvm`, `cargo`, `go`, `gcloud`, …) — missing tools are silently skipped |
| `zsh/aliases/` | Aliases: general, git, docker, terraform |
| `zsh/functions/` | Custom Zsh functions |
| `zsh/p10k/` | Powerlevel10k profiles (auto-selected, see below) |
| `tmux/` | tmux config, plugins list, `t` layout launcher — self-contained |
| `fastfetch/` | fastfetch layout + logo image (`config.jsonc`, `logo.png`, spare logos in `alt/`), self-contained |
| `niri/` | niri window manager config + keybinds (`config.kdl`, `binds.kdl`), self-contained |
| `noctalia/` | noctalia shell settings (`settings.toml`), self-contained |
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
- Symlinks `fastfetch/config.jsonc` and `fastfetch/logo.png` to `~/.config/fastfetch/` (every box, servers included)
- If `niri` is on PATH: symlinks `niri/` to `~/.config/niri` and deploys `noctalia/settings.toml`. Skipped entirely on boxes without niri (servers, jump hosts)
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

## fastfetch

Minimalist system readout: host, os, kernel, uptime, screen / cpu, load, avg, ram, disk. Symlinked to `~/.config/fastfetch/` on every box, servers included.

It runs at shell startup from `.zshrc`, deliberately placed **above the Powerlevel10k instant prompt preamble**. Below that line p10k captures console output, which trips its "console output during zsh initialization" warning *and* costs fastfetch its tty — so the image logo silently degrades to ASCII art. Keep it where it is.

```sh
sh ~/dotfiles/fastfetch/install.sh
```

The logo is a **real image** (`logo.png` — earth at the terminator, shot by the Artemis II crew, from [artemis-ii-wallpapers](https://github.com/JadenMajid/artemis-ii-wallpapers)) drawn with the kitty graphics protocol — ghostty and kitty render it, anything else falls back to distro ASCII art. Two gotchas, both silent:

- **ImageMagick is a hidden dependency.** fastfetch `dlopen()`s it at runtime and does not declare it as a package dependency, so a stock `apt install fastfetch` renders ASCII art and never says why. `packages.sh` installs it now (`libmagickcore-7.q16hdri-10` on Debian/Ubuntu, `imagemagick` on Arch/macOS). If a logo won't draw, `fastfetch --show-errors` is the only thing that tells you.
- **The keys use Nerd Font icons**, Font Awesome 4 range (stable across Nerd Fonts v2 and v3 — the Material Design range is not, it was remapped). Install a Nerd Font first: `sh ~/dotfiles/tmux/fonts.sh`.

Swap the logo by replacing `fastfetch/logo.png` — square images with a transparent background work best in the 20×10 cell box. **Then clear the cache**, or you'll keep seeing the old image: fastfetch caches the encoded logo under `~/.cache/fastfetch/images` keyed by source path and pixel size, not by content, so a same-size replacement goes unnoticed. `install.sh` clears it; by hand it's `rm -rf ~/.cache/fastfetch/images`. `alt/` holds spares (`niri.png`, plus `niri.svg` to recolor and re-render).

For another planet-from-orbit shot, `mklogo.py` does the background removal (needs `python3-pil`, `python3-numpy`):

```sh
./fastfetch/mklogo.py ~/Downloads/some-earth.jpg fastfetch/logo.png
```

It least-squares-fits a circle to the lit limb, makes everything outside it transparent, and smoothsteps the night side out — which also hides the flat edge you get when the photo clips the disc. It prints the fit residual; anything over ~3px means the limb was occluded and the result needs a look.

No ImageMagick CLI on the box? Headless Chrome rasterizes an SVG fine:

```sh
google-chrome --headless --window-size=512,512 --default-background-color=00000000 \
  --screenshot=logo.png file://$PWD/alt/niri.svg
```

## niri / noctalia

Wayland window manager + shell, laptop/desktop only. Never installed on servers (`install.sh` checks `command -v niri` and skips otherwise).

- `niri/config.kdl` + `niri/binds.kdl` are symlinked into `~/.config/niri/`, same as everything else in this repo: edit the repo copy, `git pull` deploys it.
- `niri/noctalia.kdl` is **not** symlinked, only seeded once if missing. Noctalia's theme engine owns and rewrites this file on every theme/palette change; `config.kdl` just needs it to exist so `include "noctalia.kdl"` doesn't fail niri's very first start.
- `noctalia/settings.toml` is **copy-deployed** to `~/.local/state/noctalia/settings.toml` (previous version saved as `.bak`), the same pattern as the Windows profile above. The live file gets rewritten by the app (wallpaper picks, panel state), so symlinking it would make normal use dirty the git tree. Tweak something in the app you want to keep → copy it back into the repo by hand, then commit.

```bash
sh ~/dotfiles/niri/install.sh
sh ~/dotfiles/noctalia/install.sh
```

Both also run automatically from the main `install.sh` when niri is present.

### Ghostty over SSH looks broken (double-typed input, doubled prompts)

Not a dotfiles bug. Ghostty (not installed by this repo, just `apt install ghostty`) sets `TERM=xterm-ghostty`, and almost no remote host has that terminfo entry. The shell falls back to raw rendering, which looks exactly like keystrokes and prompts being duplicated. Fix per host:

```bash
infocmp -x xterm-ghostty | ssh <host> -- tic -x -
```

Purely additive: adds a terminfo entry, doesn't touch `xterm-256color` or anything else already there, so other clients (e.g. Windows) SSHing into the same host are unaffected. Needs re-running once per new host you SSH into.

---

## OS notes

| OS | Script | Why it's separate |
|---|---|---|
| macOS | `macos/packages.sh` | Homebrew assumed present; `bat` and `eza` install cleanly under their own names |
| Arch | `arch/packages.sh` | Everything via pacman, including `eza` |
| Ubuntu | `ubuntu/packages.sh` | apt's zoxide is outdated → installed from upstream; `bat`/`fd` install as `batcat`/`fdfind` → symlinked into `~/.local/bin`; also installs `wl-clipboard` (Wayland clipboard, needed by niri/tmux-yank) |
| Debian | `debian/packages.sh` | apt zoxide is fine; same `batcat`/`fdfind` symlinks. Kali lands here (`/etc/debian_version`) — but Kali should use the tmux-only install instead |

Packages everywhere: git, curl, zsh, fzf, ripgrep, bat, fd, jq, btop, delta, zoxide, entr, tmux (+ eza on macOS/Arch).

---

## Not managed here

Desktop environments, GUI apps, system services, OS configuration — anything needing root beyond package installs.

## License

Personal use. Adapt freely.
