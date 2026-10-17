<div align="center">

<img src="fastfetch/logo.png" width="112" alt="Earth logo" />

# Dotfiles

**A familiar terminal, wherever you log in.**

Personal shell and desktop settings for Linux, macOS, and Windows.

<p>
  <a href="#everyday-use"><img src="https://img.shields.io/badge/Zsh-89b4fa?style=for-the-badge&amp;logo=zsh&amp;logoColor=1e1e2e" alt="Zsh" /></a>
  <a href="#everyday-use"><img src="https://img.shields.io/badge/tmux-a6e3a1?style=for-the-badge&amp;logo=tmux&amp;logoColor=1e1e2e" alt="tmux" /></a>
  <a href="#windows"><img src="https://img.shields.io/badge/PowerShell-7-cba6f7?style=for-the-badge&amp;labelColor=313244" alt="PowerShell 7" /></a>
  <a href="#customize"><img src="https://img.shields.io/badge/Catppuccin-f5c2e7?style=for-the-badge&amp;logo=catppuccin&amp;logoColor=1e1e2e" alt="Catppuccin theme" /></a>
</p>

<p>
  <a href="macos/packages.sh"><img src="https://img.shields.io/badge/macOS-313244?style=flat-square" alt="macOS setup" /></a>
  <a href="arch/packages.sh"><img src="https://img.shields.io/badge/Arch_Linux-313244?style=flat-square&amp;logo=archlinux&amp;logoColor=89b4fa" alt="Arch Linux setup" /></a>
  <a href="ubuntu/packages.sh"><img src="https://img.shields.io/badge/Ubuntu-313244?style=flat-square&amp;logo=ubuntu&amp;logoColor=fab387" alt="Ubuntu setup" /></a>
  <a href="debian/packages.sh"><img src="https://img.shields.io/badge/Debian-313244?style=flat-square&amp;logo=debian&amp;logoColor=f38ba8" alt="Debian setup" /></a>
  <a href="#windows"><img src="https://img.shields.io/badge/Windows-313244?style=flat-square" alt="Windows setup" /></a>
</p>

<p>
  <a href="#install"><strong>Get started</strong></a> ·
  <a href="TMUXCheatSheet.md"><strong>Keybindings</strong></a> ·
  <a href="troubleshoot.md"><strong>Troubleshooting</strong></a>
</p>

</div>

---

Zsh suggestions and shortcuts, persistent tmux sessions, and optional niri and Noctalia desktop settings. Powerlevel10k prompts, Catppuccin colors, Nerd Font icons, and fastfetch artwork give each machine a consistent look. Remote shells have a distinct prompt and a text logo so you can tell where you are working.

**On this page:** [Install](#install) · [Everyday use](#everyday-use) · [Customize](#customize) · [Update](#update) · [Remove](#remove) · [Files](#files)

## Install

Clone the complete repository and keep it at that location: most installed files link back to it.

```sh
git clone https://github.com/ghimireaacs/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Choose the setup you need:

| Setup | Command | Requirements |
|---|---|---|
| Packages, Zsh, tmux, and fastfetch | `bash bootstrap.sh` | macOS, Arch, Ubuntu, or Debian; Git and Bash to start; sudo on Linux; Homebrew on macOS |
| Shell configuration without package installation | `zsh install.sh` | Zsh, Git, curl, and tmux already installed |
| tmux only | `sh tmux/install.sh` | tmux and Git |
| fastfetch configuration and logo | `sh fastfetch/install.sh` | fastfetch to display the result |
| Windows PowerShell | `pwsh -File windows/install.ps1` | PowerShell 7, Scoop, and winget if oh-my-posh is missing |

An internet connection is needed for packages, themes, and plugins. Bootstrap installs command-line tools such as fzf, ripgrep, bat, fd, jq, btop, delta, and zoxide. Package availability depends on your OS release. On Arch, the package command also upgrades the system.

The full shell installer:

- Installs Oh My Zsh, Powerlevel10k, autosuggestions, and syntax highlighting.
- Links the shell files, tmux configuration, and fastfetch artwork into your home directory.
- Installs tmux plugins and links the `t` layout command into `~/.local/bin`.
- Sets delta as the global Git pager when available and changes your login shell to Zsh.

Existing files are moved to `.bak`, then `.bak.1`, `.bak.2`, and so on. Earlier backups are kept. Running an installer again leaves matching links and unchanged copied files alone.

Open a new terminal after installation. If the login shell changed, log out and back in. Install fonts on the machine displaying the terminal, including your local machine when using SSH:

```sh
sh tmux/fonts.sh
```

That font installer requires `fc-cache`. On other systems, install MesloLGS NF manually and select it in your terminal settings.

### Optional desktop settings

Shell installation does not apply desktop settings automatically. After installing niri, Noctalia, and the applications used by the keybindings:

```sh
sh niri/install.sh
sh noctalia/install.sh
```

Niri's main configuration and keybindings are linked. Its Noctalia theme file is copied only when missing. Noctalia settings are copied because the app rewrites them during use. Rerunning its installer deliberately replaces your live preferences after backing them up.

Noctalia and Waybar start with niri. Custom bindings are in `niri/binds.kdl`; they use Ghostty, Zen, Helium, and Nautilus. Other bindings in `niri/config.kdl` use additional desktop tools. Those applications are not installed here.

### Windows

You can also launch `windows\install.bat`. The installer copies the PowerShell profile, prompt theme, and fastfetch settings, with backups of changed destination files. Open a new PowerShell tab afterward. Windows copies need the installer rerun after repository updates.

## Everyday use

- Zsh offers suggestions, syntax highlighting, and fzf integration.
- `cd` uses zoxide when installed. `cat` uses bat when installed. Normal commands remain available when those tools are missing.
- `ls`, `ll`, `la`, and `tree` use eza when available.
- `myalias` lists custom shortcuts; `myalias git` shows one group.
- `dockstat` shows a compact Docker container table.
- tmux uses `Ctrl+Space` as its prefix. `prefix o` opens the session picker; `prefix p` opens the floating terminal.
- `t nmap` opens a three-pane layout; `t recon` opens a main pane and a smaller log pane. `prefix T` opens the layout menu.

Tmux retains its theme, clipboard tools, text and URL pickers, and session saving. Scrollback is limited to 50,000 lines per pane. See the [key reference](TMUXCheatSheet.md) for details.

## Customize

Put machine-specific shell settings in `~/.zshrc.local`, which loads last. Edit tracked configuration in this checkout when you want changes on all machines.

Prompt settings live in `zsh/p10k/`: SSH and sessions without a display use `server.zsh`; local graphical sessions and WSL use `workstation.zsh`. The workstation profile builds on the server profile. Keep `.p10k.zsh` as the selector; do not overwrite it with the prompt configuration wizard.

Fastfetch runs before the prompt initializes so the logo can draw correctly. Keep it there. To disable the startup banner, put `export DOTFILES_FASTFETCH=0` in `~/.zshenv`. Running `fastfetch` manually still works.

To keep Noctalia changes made through its interface, copy `~/.local/state/noctalia/settings.toml` back into `noctalia/settings.toml` before committing. Its current panel settings include the display name `eDP-1`; adjust that for another machine.

## Update

```sh
cd ~/dotfiles
git pull --ff-only
```

| What changed | Apply it |
|---|---|
| Linked Zsh files | Open a new shell |
| Linked tmux configuration | Press `prefix r` |
| New installer behavior or new links | Run `zsh install.sh`, or the component installer you use |
| fastfetch logo | Run `sh fastfetch/install.sh` to clear its image cache |
| Noctalia settings | Run `sh noctalia/install.sh` when you want the repository version |
| Windows files | Rerun the Windows installer |
| Packages or plugins | Update separately; `git pull` only updates this repository |

Linked niri files change with the checkout; validate the configuration before reloading a desktop session. The troubleshooting guide covers this and plugin updates.

## Remove

Run from the same checkout used to install:

```sh
zsh uninstall.sh
```

This removes only links pointing to this checkout and restores the highest numbered backup available, or `.bak` if there are no numbered backups. Files and links owned by another setup are left alone.

Packages, Oh My Zsh, downloaded plugins, login-shell selection, Git settings, and copied niri/Noctalia/Windows files remain. See [recovery instructions](troubleshoot.md#uninstall-and-backups) to handle those deliberately. Keep the checkout until its links have been removed.

## Files

| Path | Purpose |
|---|---|
| `bootstrap.sh`, `<os>/packages.sh` | OS detection and package installation |
| `install.sh`, `uninstall.sh`, `lib/files.sh` | Setup, removal, and shared backup handling |
| `.zshrc`, `.p10k.zsh`, `zsh/` | Shell settings, prompt profiles, and shortcuts |
| `tmux/` | Configuration, plugin list, fonts, and layout launcher |
| `fastfetch/` | System information display, artwork, and optional logo-making tools |
| `niri/`, `noctalia/` | Optional desktop settings |
| `cbin/` | Small command-line helpers |
| `windows/` | PowerShell profile, theme, and installer |
| `tests/` | Isolated checks for installers and layouts |

System services and network configuration are outside this repository's scope. The old `dockerTCP.sh` helper has been removed; updating this checkout does not undo changes it previously made.

## License

Personal use. Adapt freely.
