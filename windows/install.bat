@echo off
rem Double-clickable wrapper - bypasses execution policy for install.ps1
where pwsh >nul 2>&1
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
)
pause
