@echo off
setlocal enabledelayedexpansion

:: Clear invalid GITHUB_TOKEN to allow keyring auth to succeed
set GITHUB_TOKEN=

echo ===================================================
echo   SZA Portfolio Deployer - Auto-publish to GitHub
echo ===================================================
echo.

:: Check if git is initialized
if not exist .git (
    echo [ERROR] Git is not initialized here. Initializing git..
    git init
    git branch -M main
)

:: Check if remote exists, if not add it. `git remote | findstr /R "^origin$"` never matched: git prints
:: LF-only lines and findstr's `$` anchor wants CR, so every run tried to re-add an existing remote.
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo [INFO] Adding remote origin..
    git remote add origin https://github.com/SerZhyAle/sza.od.ua.git
)

:: Canon compliance gate. The site has no release boundary, so this publish IS the gate scope: whatever
:: is wrong here reaches sza.od.ua about a minute after the push. Set SZA_SKIP_GATE=1 to publish anyway.
set "PWSH="
where /q pwsh.exe && set "PWSH=pwsh.exe"
if not defined PWSH if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set "PWSH=%ProgramFiles%\PowerShell\7\pwsh.exe"

set "SZA_GATE_FAILED="
if defined SZA_SKIP_GATE (
    echo [WARN] SZA_SKIP_GATE is set - compliance gate skipped by request.
) else if not defined PWSH (
    echo [WARN] PowerShell 7 not found - compliance gate skipped.
) else (
    echo [INFO] Running the canon compliance gate..
    "%PWSH%" -NoProfile -File "%~dp0tools\check.ps1"
    if errorlevel 1 set "SZA_GATE_FAILED=1"
)
if defined SZA_GATE_FAILED (
    echo.
    echo ===================================================
    echo   [ERROR] Compliance gate failed - nothing was
    echo   committed and nothing was pushed. Fix the errors
    echo   above, or set SZA_SKIP_GATE=1 to publish anyway.
    echo ===================================================
    echo.
    pause
    exit /b 1
)

echo [INFO] Staging changes..
git add .

:: Set commit message
set "commit_msg=Auto-publish portfolio: %date% %time%"
if "%~1" neq "" (
    set "commit_msg=%~1"
)

echo [INFO] Committing changes: "%commit_msg%"..
git commit -m "%commit_msg%"

echo [INFO] Pushing to GitHub (main)..
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ===================================================
    echo   [SUCCESS] Deployment complete!
    echo   If configured, your website sza.od.ua will update.
    echo ===================================================
) else (
    echo.
    echo ===================================================
    echo   [ERROR] Push failed. Check your connection / auth.
    echo ===================================================
)

echo.
pause
