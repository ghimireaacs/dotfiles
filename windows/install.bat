@echo off
rem Run the installer in PowerShell 7, which is also required by the profile.
where pwsh >nul 2>&1
if errorlevel 1 (
    echo PowerShell 7 is required. Install it, then run this file again.
    pause
    exit /b 1
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set "install_result=%errorlevel%"
pause
exit /b %install_result%
