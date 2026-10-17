# Troubleshooting

Start with the symptom below. These are known failure points and likely causes, not measured failure rates. Commands assume the checkout is at `~/dotfiles`; adjust that path if yours differs.

## Changes to expect after this cleanup

- Shell setup no longer applies niri or Noctalia preferences. Use their installers explicitly.
- `t` is now linked into `~/.local/bin`; tmux-only users may need that directory on PATH.
- Backups accumulate instead of replacing earlier backups. Uninstall restores the highest numbered backup, which may differ from the original `.bak`.
- tmux keeps 50,000 scrollback lines per pane. The extra `tmux-fzf` session picker was removed; use `prefix o` for sessionx or `prefix s` for tmux's built-in list.
- Niri uses your custom bindings where stock entries overlapped.
- `dockstat` is a small Docker table command. `dockerTCP.sh` was removed.
- Themes, prompt styles, icons, fastfetch artwork, and the floating terminal remain.

## Installation stops partway through

Read the first error, not just the final line. Completed steps are not rolled back automatically.

| Error or symptom | Check and fix |
|---|---|
| `zsh`, `git`, `curl`, or `tmux` missing | Run `bash bootstrap.sh` to install packages, or install the missing tools before running `zsh install.sh`. |
| Homebrew missing | Install Homebrew before using the macOS package script. |
| Package unavailable | Check your OS release and repositories. The package lists are not tested against every release. fastfetch is skipped on apt systems when unavailable; other missing packages can stop installation. |
| Download or clone fails | Check connectivity and the reported repository URL, then rerun the same installer. An incomplete clone directory may need inspection before retrying. |
| `lib/files.sh` missing | Use the complete checkout. Component installers now share this file; copying just their directory is insufficient. |
| Login-shell change fails | Confirm Zsh is installed and listed in `/etc/shells`. Run `zsh` directly while resolving the account or permission issue. |

Do not run the whole setup with `sudo`: package commands request elevated access when needed, but configuration belongs in your own home directory.

## Shell startup fails, hangs, or prints warnings

Start a shell without loading the user configuration:

```sh
zsh -f
# Or:
bash --noprofile --norc
```

Check the main files without executing them:

```sh
zsh -n ~/dotfiles/.zshrc
zsh -n ~/dotfiles/.p10k.zsh
zsh -n ~/dotfiles/zsh/p10k/server.zsh
```

Also inspect `~/.zshrc.local`. It loads last and can override repository settings. Undo the recent edit, then open a new terminal. A syntax check will not find missing tools or every runtime error.

For Powerlevel10k's startup-output warning, keep fastfetch above the instant-prompt block. Other startup commands that print output can also trigger the warning. Do not silence the warning before identifying the command.

To check whether fastfetch is delaying startup:

```sh
DOTFILES_FASTFETCH=0 zsh
```

If you prefer no startup banner, add `export DOTFILES_FASTFETCH=0` to `~/.zshenv`. Remove that line to restore it. Putting it in `~/.zshrc.local` is too late for the current shell's banner.

## `cd`, `cat`, `code`, or `t` behaves differently

In Zsh, inspect the command actually being used:

```sh
whence -va cd cat code t
command -v zoxide bat batcat codium
```

The repository only replaces `cd` and `cat` when their replacement tools exist. It maps `code` to Codium only when Codium exists and `code` does not. An already-open shell can retain old aliases after an update; open a fresh shell.

For a one-off use of the original command, run `builtin cd /path` or `command cat file`. Put `unalias cd` or `unalias cat` in `~/.zshrc.local` if you prefer the original behavior and that alias is present.

For a missing `t` command:

```sh
sh ~/dotfiles/tmux/install.sh
~/.local/bin/t
```

If the full path works, add `export PATH="$HOME/.local/bin:$PATH"` to your shell's startup file. The supplied Zsh configuration already does this. The menu at `prefix T` also works without a PATH change.

## Links broke after moving or deleting the checkout

Inspect where they point:

```sh
readlink ~/.zshrc
readlink ~/.config/tmux
readlink ~/.local/bin/t
```

Move the checkout back, or rerun the appropriate installers from its new location. Old links are backed up, including broken links. Uninstall from the new checkout can restore those old, broken links; inspect the backups before choosing what to keep.

Uninstall intentionally leaves a link alone if it points to another checkout. Run uninstall from the checkout that owns it, or inspect and remove that individual link yourself.

## Uninstall and backups

```sh
cd ~/dotfiles
zsh uninstall.sh
```

The script removes links owned by this checkout and restores the highest numbered backup at each destination. Earlier backups remain. A second run leaves restored files and unrelated links alone.

For example, `.zshrc.bak` might be your original file, while `.zshrc.bak.2` is a later configuration. Inspect their contents before restoring an older one. Use `ls -la ~` to see hidden backup files. After uninstall has removed a managed link, rename any current file you want to keep, then copy your chosen backup into place. Do not copy onto a live symlink: that can overwrite its target in the repository.

Uninstall deliberately leaves these items:

| Item | How to handle it |
|---|---|
| Login shell | Use `chsh` to choose a shell listed in `/etc/shells`, then log in again. |
| Git pager | Inspect `git config --global --get core.pager` and `git config --global --get interactive.diffFilter`. Restore previous values if you had them. If delta is no longer wanted, unset these keys and `delta.navigate`; the installer did not record their previous values. |
| Oh My Zsh and plugins | Keep them if another configuration uses them. Remove their directories only after checking that dependency. |
| System packages | Manage them with the OS package manager. Other applications may use them. |
| Noctalia settings and generated niri theme | Restore a chosen backup manually if needed. The app can rewrite live settings, so close it before restoring and start it again afterward. |
| Windows copies | Restore the chosen `.bak` file beside each destination, then open a new PowerShell tab. |

For Git settings that you have confirmed should be removed:

```sh
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
git config --global --unset delta.navigate
```

An unset command can return a nonzero status when the key is already absent.

## tmux theme, plugins, layouts, or clipboard fail

The prefix is `Ctrl+Space`. Try `prefix ?` to see the active keys.

- **Theme or popup missing:** run `sh ~/dotfiles/tmux/install.sh`, then reload with `prefix r`. Plugins live in `~/.tmux/plugins`, outside this checkout.
- **Plugin update needed:** use TPM's `prefix U` update menu. Pulling this repository does not update downloaded plugins. `prefix I` installs missing plugins.
- **Old picker still responds:** a running server may retain bindings from a removed plugin. Inspect `prefix ?`. Start a fresh server after saving your work; reloading a file does not necessarily erase old bindings. You can remove the unused `~/.tmux/plugins/tmux-fzf` directory once it is no longer in use.
- **`prefix p` opens a popup:** this is intentional. Use `prefix Ctrl+h` for the previous window.
- **Layout opens existing panes:** `t nmap` and `t recon` reuse sessions with those names. Rename the old session first if you want a new layout. New panes are explicitly targeted so another active session is not split by mistake.
- **Less old output available:** scrollback is now 50,000 lines per pane. Save important output to a file or increase `history-limit` in `tmux/tmux.conf`; already discarded output cannot be recovered.
- **Mouse copy does not reach the clipboard:** check for `wl-copy` on Wayland, `xclip`/`xsel` on X11, or `pbcopy` on macOS. Over SSH, clipboard behavior also depends on the local terminal and its settings.

Do not use `tmux kill-server` as a routine fix: it closes every session on that server.

## Icons are boxes, or fastfetch shows no image

Install a Nerd Font on the machine displaying the terminal, then select it in that terminal's preferences. Installing a font only on an SSH server does not fix local rendering.

```sh
sh ~/dotfiles/tmux/fonts.sh
fastfetch --show-errors
```

The font script requires `fc-cache`; otherwise install the font manually. The configured image output uses the kitty graphics protocol, so test outside tmux in a compatible terminal such as Ghostty or kitty. Remote shells deliberately request a text logo. Image support and fallback behavior can differ between terminals and fastfetch versions.

If fastfetch reports a missing ImageMagick library, use the matching package for your OS release. The OS package scripts try to install a suitable library; do not blindly copy a version-specific package name from another machine.

After replacing the logo, clear the image cache by rerunning:

```sh
sh ~/dotfiles/fastfetch/install.sh
```

This keeps the artwork links in place and removes fastfetch's cached images, which are regenerated on the next run.

### Editing the logo

Replace `fastfetch/logo.png` with another image. Square images with transparency fit the current layout best. Spare niri artwork is in `fastfetch/alt/`. Earth image attribution: [artemis-ii-wallpapers](https://github.com/JadenMajid/artemis-ii-wallpapers).

The optional `fastfetch/mklogo.py` tool removes the background from a planet image. It requires Pillow and NumPy:

```sh
python3 ~/dotfiles/fastfetch/mklogo.py ~/Downloads/earth.jpg ~/dotfiles/fastfetch/logo.png
sh ~/dotfiles/fastfetch/install.sh
```

Inspect the resulting image; its circle-fitting method will not suit every photograph.

## SSH shows duplicated input or broken prompts

Check `echo "$TERM"` locally and remotely. For a Ghostty terminal whose remote host lacks its terminal description, run this from the local machine, replacing `my-host`:

```sh
infocmp -x xterm-ghostty | ssh my-host -- tic -x -
```

This requires the local description and the remote `tic` command. Reconnect afterward. Terminal descriptions are one possible cause; also test outside tmux and inspect shell startup output if the problem continues.

## Niri or Noctalia settings do not apply

Shell setup no longer applies desktop files. Apply them explicitly:

```sh
sh ~/dotfiles/niri/install.sh
sh ~/dotfiles/noctalia/install.sh
```

The second command replaces live Noctalia preferences with the repository copy and keeps a backup. Save any live changes you want to retain before running it.

Validate niri's configuration before reloading:

```sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

Run the reload only if validation succeeds. If validation fails, fix the reported file and line or restore the previous configuration from a separate terminal/session.

- `noctalia.kdl` is created only when missing, then owned by Noctalia's theme generator. It is not a linked file.
- Custom shortcuts live in `niri/binds.kdl`. Avoid defining the same shortcut again in `config.kdl`.
- If an application shortcut does nothing, check whether that application is installed. This repository does not install desktop apps.
- If a panel is missing or on the wrong screen, compare `niri msg outputs` with the `eDP-1` setting in `noctalia/settings.toml`.
- The existing startup entries for Noctalia and Waybar are both kept. If you see two panels and only want one, remove the unwanted startup entry from `niri/config.kdl`.

## Windows setup or profile fails

Open a clean session with `pwsh -NoProfile`, then check:

```powershell
$PROFILE
Get-Command scoop, winget, oh-my-posh, zoxide, fastfetch -ErrorAction SilentlyContinue
```

The installer targets PowerShell 7, not Windows PowerShell 5.1. Use the same PowerShell application for installation and everyday use. If a newly installed command is missing, open a new terminal so it sees updated PATH entries, then rerun the installer.

Profile/theme backups sit beside `$PROFILE`; fastfetch backups sit in `~\.config\fastfetch`. Rerunning skips identical files and backs up changed ones. If a module download fails, resolve the reported PowerShell Gallery or network error before retrying. These files are copies, so `git pull` alone will not refresh them.

## Docker helper changes

`dockstat` now delegates to `docker ps -a` and reports Docker errors directly. If it cannot connect, check your existing Docker service/context and permissions; the helper no longer mistakes a failed connection for an empty container list.

The removed `dockerTCP.sh` wrote `/etc/docker/daemon.json`, wrote `/etc/systemd/system/docker.service.d/override.conf`, restarted Docker, and opened TCP port 2375 through UFW when active. It configured a listener on every interface without TLS settings.

Deleting the script does **not** undo those changes. If you previously ran it, inspect those files and your firewall rules. Restore your intended Docker configuration and remove the matching firewall allowance if no longer needed. The old script did not preserve previous files, so there is no reliable automatic rollback. Plan any Docker restart around running containers.

## Check repository changes

From the checkout:

```sh
python3 -m unittest discover -s tests -v
```

The checks use temporary directories, stub external setup commands, and a separate tmux server. They do not install packages or change your live configuration. They require Python 3, Zsh, and tmux for the complete suite. Desktop rendering and Windows behavior still need checks on those platforms.
