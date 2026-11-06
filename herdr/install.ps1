# Install the tmux-style Herdr config on Windows.
# Run from this folder:  powershell -ExecutionPolicy Bypass -File .\install.ps1
$ErrorActionPreference = 'Stop'
$src  = $PSScriptRoot
$dest = if ($env:HERDR_APP_HOME) { $env:HERDR_APP_HOME } else { Join-Path $HOME '.config\herdr-app' }
if (-not (Test-Path $dest)) { throw "No Herdr config at $dest - start Herdr once first (or set HERDR_APP_HOME)." }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

# keys.json: Herdr defaults + Ctrl+Space prefix. Back up whatever is there.
$keys = Join-Path $dest 'keys.json'
if (Test-Path $keys) { Copy-Item $keys "$keys.bak-$stamp" }
Copy-Item (Join-Path $src 'keys.json') $keys -Force

# mod + theme
foreach ($d in 'mods\ghost-prefix', 'themes') {
  New-Item -ItemType Directory -Force (Join-Path $dest $d) | Out-Null
  Copy-Item (Join-Path $src "$d\*") (Join-Path $dest $d) -Recurse -Force
}

# settings.json: set the theme, keep everything else
$settings = Join-Path $dest 'settings.json'
$s = if (Test-Path $settings) { Copy-Item $settings "$settings.bak-$stamp"; Get-Content $settings -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
$s | Add-Member -NotePropertyName theme -NotePropertyValue 'catppuccin-mocha' -Force
$s | ConvertTo-Json -Depth 20 | Set-Content $settings -Encoding utf8

Write-Host "Installed to $dest (backups: *.bak-$stamp). Applies live - press Ctrl+Space in Herdr."
