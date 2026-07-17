# PowerShell profile — lean catppuccin, matches the WSL/tmux look.
# Theme: catppuccin-lean.omp.json (mirrors the p10k workstation prompt).

oh-my-posh init pwsh --config "$PSScriptRoot\catppuccin-lean.omp.json" | Invoke-Expression
zoxide init --cmd z powershell | Out-String | Invoke-Expression
Import-Module -Name Terminal-Icons

# System info at startup (config: ~\.config\fastfetch\config.jsonc)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) { fastfetch }

# History & Colors — catppuccin mocha
Set-PSReadLineOption -PredictionViewStyle ListView -Colors @{
    Command   = '#89b4fa'
    Parameter = '#94e2d5'
    Operator  = '#f5c2e7'
    Variable  = '#fab387'
    String    = '#a6e3a1'
    Number    = '#f9e2af'
    Type      = '#cba6f7'
    Comment   = '#6c7086'
    Keyword   = '#cba6f7'
    Error     = '#f38ba8'
}

# Keybinds
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# File / Directory Utilities
function touch ($File) {
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    } else {
        New-Item $File -ItemType File | Out-Null
    }
}

function mkcd ($Path) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Set-Location -Path $Path
}

function trash ($Path) {
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path,'OnlyErrorDialogs','SendToRecycleBin')
    } else {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path,'OnlyErrorDialogs','SendToRecycleBin')
    }
}

function ff ($Name) {
    Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName
}

function head ($Path) {
    Get-Content $Path -Head 10
}

function sed ($File, $Find, $Replace) {
    (Get-Content $File).replace("$Find", $Replace) | Set-Content $File
}

function which ($Name) {
    (Get-Command $Name).Source
}

function pgrep ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue
}

function pkill ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function k9 ($Name) {
    pkill $Name
}

# System Utilities
function uptime {
    (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds
}

function winutil {
    Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gp { git push }
function gpull { git pull }
function gcl { git clone $args }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

function docs {
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}

# Listing / Viewing
function la {
    Get-ChildItem | Format-Table -AutoSize
}

function ll {
    Get-ChildItem -Force | Format-Table -AutoSize
}

# Aliases
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name grep -Value Select-String

# Help Function
function Show-Help {
    $title    = $PSStyle.Foreground.BrightMagenta
    $section  = $PSStyle.Foreground.BrightBlue
    $command  = $PSStyle.Foreground.BrightGreen
    $desc     = $PSStyle.Foreground.BrightWhite
    $accent   = $PSStyle.Foreground.BrightYellow
    $dim      = $PSStyle.Foreground.BrightBlack
    $reset    = $PSStyle.Reset

    Write-Host @"
${title}󰘳 PowerShell Profile Help${reset}
${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}

${section}󰊢 Git Shortcuts${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}ga${reset}                 ${accent}→${reset} ${desc}git add .${reset}
  ${command}gcl <repo>${reset}         ${accent}→${reset} ${desc}git clone${reset}
  ${command}gcom <message>${reset}     ${accent}→${reset} ${desc}add + commit${reset}
  ${command}gp${reset}                 ${accent}→${reset} ${desc}git push${reset}
  ${command}gpull${reset}              ${accent}→${reset} ${desc}git pull${reset}
  ${command}gs${reset}                 ${accent}→${reset} ${desc}git status${reset}
  ${command}lazyg <message>${reset}    ${accent}→${reset} ${desc}add + commit + push${reset}

${section}󰘴 System Shortcuts${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}docs${reset}               ${accent}→${reset} ${desc}Documents folder${reset}
  ${command}ff <name>${reset}          ${accent}→${reset} ${desc}Search files${reset}
  ${command}grep <pattern>${reset}     ${accent}→${reset} ${desc}Search text (Select-String)${reset}
  ${command}head <file>${reset}        ${accent}→${reset} ${desc}First 10 lines${reset}
  ${command}k9 <name>${reset}          ${accent}→${reset} ${desc}Kill process by name${reset}
  ${command}la / ll${reset}            ${accent}→${reset} ${desc}List files (ll incl. hidden)${reset}
  ${command}mkcd <dir>${reset}         ${accent}→${reset} ${desc}Create + enter dir${reset}
  ${command}pgrep <name>${reset}       ${accent}→${reset} ${desc}Find process by name${reset}
  ${command}pkill <name>${reset}       ${accent}→${reset} ${desc}Stop process by name${reset}
  ${command}sed <file> <find> <replace>${reset} ${accent}→${reset} ${desc}Replace text${reset}
  ${command}touch <file>${reset}       ${accent}→${reset} ${desc}Create file${reset}
  ${command}trash <path>${reset}       ${accent}→${reset} ${desc}Delete to Recycle Bin${reset}
  ${command}unzip <file>${reset}       ${accent}→${reset} ${desc}Extract zip${reset}
  ${command}uptime${reset}             ${accent}→${reset} ${desc}System uptime${reset}
  ${command}which <name>${reset}       ${accent}→${reset} ${desc}Locate command${reset}
  ${command}winutil${reset}            ${accent}→${reset} ${desc}Run CTT WinUtil${reset}
  ${command}z <dir>${reset}            ${accent}→${reset} ${desc}zoxide jump${reset}

${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}
"@
}
