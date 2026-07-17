# Windows shell setup: pwsh profile + oh-my-posh theme + fastfetch config.
# Copies (not symlinks — those need admin on Windows); rerun after git pull to update.
$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

# --- Dependencies (all user-scoped, no admin) ---
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop not found - install it first: https://scoop.sh" -ForegroundColor Red
    exit 1
}
foreach ($tool in 'zoxide', 'fastfetch') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { scoop install $tool }
}
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    winget install --id JanDeDobbeleer.OhMyPosh --source winget
}
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
}

# --- Profile + prompt theme (into wherever $PROFILE actually lives) ---
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
foreach ($file in 'Microsoft.PowerShell_profile.ps1', 'catppuccin-lean.omp.json') {
    $target = Join-Path $profileDir $file
    # keep the very first pre-existing version as .bak, never overwrite it
    if ((Test-Path $target) -and -not (Test-Path "$target.bak")) { Copy-Item $target "$target.bak" }
    Copy-Item (Join-Path $src $file) $target -Force
}

# --- fastfetch config ---
$ffDir = Join-Path $HOME '.config\fastfetch'
New-Item -ItemType Directory -Force -Path $ffDir | Out-Null
Copy-Item (Join-Path $src 'fastfetch.jsonc') (Join-Path $ffDir 'config.jsonc') -Force

Write-Host "Done - open a new terminal tab." -ForegroundColor Green
