@echo off
REM Wrapper so you can double-click or run from cmd without touching
REM the machine's PowerShell execution policy.
REM
REM Dry run:  install-album-template.bat
REM Apply:    install-album-template.bat -Apply

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-AlbumTemplate.ps1" %*
pause
