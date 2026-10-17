"""Run with python3 -m unittest discover -s tests -v; no live setup is changed."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
ZSH = shutil.which('zsh')
TMUX = shutil.which('tmux')


class FileHandling(unittest.TestCase):
    def run_case(self, shell, script):
        with tempfile.TemporaryDirectory(prefix='dotfiles files ') as directory:
            subprocess.run(
                [shell, '-eu', '-c', '. "$1/lib/files.sh"\n' + script,
                 'test', str(REPO), directory], check=True, capture_output=True, text=True)

    def test_backups_restore_latest_and_preserve_original(self):
        for shell in filter(None, ['sh', ZSH]):
            with self.subTest(shell=shell):
                self.run_case(shell, '''
source_file="$2/source"
target_file="$2/target"
printf repo > "$source_file"
printf original > "$target_file"
link_file "$source_file" "$target_file"
link_file "$source_file" "$target_file"
[ "$(cat "$target_file.bak")" = original ]
[ ! -e "$target_file.bak.1" ]
rm "$target_file"
printf latest > "$target_file"
printf older > "$target_file.bak.3"
link_file "$source_file" "$target_file"
[ "$(cat "$target_file.bak.4")" = latest ]
restore_link "$source_file" "$target_file"
[ "$(cat "$target_file")" = latest ]
restore_link "$source_file" "$target_file"
[ "$(cat "$target_file.bak")" = original ]
[ "$(cat "$target_file.bak.3")" = older ]
''')

    def test_broken_links_directories_and_unrelated_links(self):
        for shell in filter(None, ['sh', ZSH]):
            with self.subTest(shell=shell):
                self.run_case(shell, '''
mkdir "$2/source" "$2/destination"
printf keep > "$2/destination/file"
link_file "$2/source" "$2/destination"
restore_link "$2/source" "$2/destination"
[ "$(cat "$2/destination/file")" = keep ]
ln -s "$2/missing" "$2/broken"
link_file "$2/source" "$2/broken"
restore_link "$2/source" "$2/broken"
[ "$(readlink "$2/broken")" = "$2/missing" ]
restore_link "$2/source" "$2/broken"
[ -L "$2/broken" ]
link_file "$2/source" "$2/new"
restore_link "$2/source" "$2/new"
[ ! -L "$2/new" ]
''')

    def test_copy_does_not_write_through_links_or_backup_unchanged_files(self):
        for shell in filter(None, ['sh', ZSH]):
            with self.subTest(shell=shell):
                self.run_case(shell, '''
printf repo > "$2/source"
printf external > "$2/external"
ln -s "$2/external" "$2/copy"
copy_file "$2/source" "$2/copy"
[ ! -L "$2/copy" ]
[ "$(cat "$2/external")" = external ]
[ -L "$2/copy.bak" ]
copy_file "$2/source" "$2/copy"
[ ! -e "$2/copy.bak.1" ]
''')


@unittest.skipUnless(ZSH, 'Zsh is required')
class Installers(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles setup ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / 'home'
        self.home.mkdir()
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        # Only child processes receive this isolated home; the caller is unchanged.
        self.env = dict(os.environ, HOME=str(self.home), PATH=f'{self.bin}:/usr/bin:/bin',
                        SHELL=ZSH, XDG_CACHE_HOME=str(self.root / 'cache'))
        self.env.pop('ZDOTDIR', None)
        self.env.pop('TMUX', None)
        for command in ('git', 'tmux', 'fastfetch', 'niri', 'delta'):
            self.stub(command, 'exit 0')
        for command in ('curl', 'sudo', 'chsh'):
            self.stub(command, 'echo "Unexpected system/download command" >&2; exit 99')
        for folder in ('themes/powerlevel10k', 'plugins/zsh-autosuggestions',
                       'plugins/zsh-syntax-highlighting'):
            (self.home / '.oh-my-zsh/custom' / folder).mkdir(parents=True)
        plugin_install = self.home / '.tmux/plugins/tpm/bin/install_plugins'
        plugin_install.parent.mkdir(parents=True)
        plugin_install.write_text('#!/bin/sh\nexit 0\n')
        plugin_install.chmod(0o755)

    def stub(self, name, body):
        path = self.bin / name
        path.write_text('#!/bin/sh\n' + body + '\n')
        path.chmod(0o755)

    def run_script(self, name, shell='sh'):
        return subprocess.run([shell, str(REPO / name)], env=self.env,
                              check=True, text=True, capture_output=True)

    def test_install_repeat_uninstall_with_existing_settings(self):
        zshrc = self.home / '.zshrc'
        zshrc.write_text('original shell\n')
        preferences = self.home / '.local/state/noctalia/settings.toml'
        preferences.parent.mkdir(parents=True)
        preferences.write_text('live preferences\n')
        self.run_script('install.sh', ZSH)
        self.run_script('install.sh', ZSH)
        self.assertEqual(zshrc.resolve(), REPO / '.zshrc')
        self.assertEqual((self.home / '.local/bin/t').resolve(), REPO / 'tmux/t')
        self.assertFalse((self.home / '.zshrc.bak.1').exists())
        self.assertFalse((self.home / '.config/niri').exists())
        self.assertEqual(preferences.read_text(), 'live preferences\n')
        self.run_script('uninstall.sh', ZSH)
        self.run_script('uninstall.sh', ZSH)
        self.assertEqual(zshrc.read_text(), 'original shell\n')
        self.assertFalse((self.home / '.local/bin/t').is_symlink())
        self.assertEqual(preferences.read_text(), 'live preferences\n')

    def test_desktop_backups_and_uninstall_ownership(self):
        self.run_script('niri/install.sh')
        theme = self.home / '.config/niri/noctalia.kdl'
        theme.write_text('// live theme\n')
        self.run_script('niri/install.sh')
        self.assertEqual(theme.read_text(), '// live theme\n')
        self.run_script('noctalia/install.sh')
        preferences = self.home / '.local/state/noctalia/settings.toml'
        preferences.write_text('live preferences\n')
        self.run_script('noctalia/install.sh')
        self.run_script('noctalia/install.sh')
        self.assertEqual(Path(str(preferences) + '.bak').read_text(), 'live preferences\n')
        self.assertFalse(Path(str(preferences) + '.bak.1').exists())
        unrelated = self.home / '.zshrc'
        unrelated.symlink_to(self.root / 'another checkout')
        self.run_script('uninstall.sh', ZSH)
        self.assertTrue(unrelated.is_symlink())
        self.assertFalse((self.home / '.config/niri/config.kdl').is_symlink())
        self.assertTrue(theme.exists())
        self.assertTrue(preferences.exists())

    def test_fastfetch_reinstall_keeps_backups_and_clears_cache(self):
        logo = self.home / '.config/fastfetch/logo.png'
        logo.parent.mkdir(parents=True)
        logo.write_bytes(b'old artwork')
        cache = Path(self.env['XDG_CACHE_HOME']) / 'fastfetch/images'
        cache.mkdir(parents=True)
        (cache / 'old').write_text('stale')
        self.run_script('fastfetch/install.sh')
        self.run_script('fastfetch/install.sh')
        self.assertEqual(Path(str(logo) + '.bak').read_bytes(), b'old artwork')
        self.assertFalse(Path(str(logo) + '.bak.1').exists())
        self.assertFalse(cache.exists())

    def test_aliases_preserve_commands_when_optional_tools_are_missing(self):
        script = '''
source "$1/zsh/aliases/general.alias"
source "$1/zsh/aliases/functioned.alias"
(( ${+aliases[cd]} == 0 ))
(( ${+aliases[cat]} == 0 ))
(( ${+aliases[code]} == 0 ))
(( ${+aliases[hostname]} == 0 ))
'''
        subprocess.run([ZSH, '-fe', '-c', script, 'test', str(REPO)],
                       env=dict(self.env, PATH=str(self.bin)), check=True, capture_output=True)

    def test_aliases_use_available_tools_without_hiding_code(self):
        for name in ('bat', 'zoxide', 'codium', 'code'):
            self.stub(name, 'exit 0')
        script = '''
source "$1/zsh/aliases/general.alias"
source "$1/zsh/aliases/functioned.alias"
[[ ${aliases[cat]} == 'bat -pp' ]]
[[ ${aliases[cd]} == z ]]
(( ${+aliases[code]} == 0 ))
'''
        subprocess.run([ZSH, '-fe', '-c', script, 'test', str(REPO)],
                       env=dict(self.env, PATH=str(self.bin)), check=True, capture_output=True)


@unittest.skipUnless(TMUX, 'tmux is required')
class Layouts(unittest.TestCase):
    def test_layouts_leave_another_session_untouched(self):
        with tempfile.TemporaryDirectory(prefix='dotfiles-tmux-') as directory:
            root = Path(directory)
            socket = root / 'socket'
            def tmux(*args, check=True):
                result = subprocess.run([TMUX, '-S', str(socket), '-f', '/dev/null', *args],
                                        capture_output=True, text=True)
                if check and result.returncode:
                    self.fail(result.stderr)
                return result
            try:
                tmux('new-session', '-d', '-s', 'existing', '-x', '160', '-y', '50', 'sleep 300')
                tmux('set-option', '-g', 'default-command', 'sleep 300')
                tmux('set-option', '-g', 'default-shell', '/bin/sh')
                tmux('set-option', '-g', 'pane-base-index', '1')
                wrapper = root / 'tmux'
                # Skip only the interactive attach; every layout operation uses real tmux.
                wrapper.write_text('#!/bin/sh\ncase "$1" in attach|switch-client) exit 0;; esac\n'
                                   'exec "$TEST_TMUX" -S "$TEST_SOCKET" "$@"\n')
                wrapper.chmod(0o755)
                env = dict(os.environ, PATH=f'{root}:/usr/bin:/bin', TEST_TMUX=TMUX,
                           TEST_SOCKET=str(socket))
                for layout, panes in [('nmap', 3), ('recon', 2)]:
                    for attempt in range(2):
                        subprocess.run(['sh', str(REPO / 'tmux/t'), layout], env=env,
                                       check=True, capture_output=True)
                        self.assertEqual(len(tmux('list-panes', '-t', layout).stdout.splitlines()), panes)
                        self.assertEqual(len(tmux('list-panes', '-t', 'existing').stdout.splitlines()), 1)
            finally:
                tmux('kill-server', check=False)


if __name__ == '__main__':
    unittest.main()
