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
    echo [ERROR] Git is not initialized here. Initializing git...
    git init
    git branch -M main
)

:: Check if remote exists, if not add it
git remote | findstr /R "^origin$" >nul
if errorlevel 1 (
    echo [INFO] Adding remote origin...
    git remote add origin https://github.com/SerZhyAle/sza.od.ua.git
)

echo [INFO] Staging changes...
git add .

:: Set commit message
set "commit_msg=Auto-publish portfolio: %date% %time%"
if "%~1" neq "" (
    set "commit_msg=%~1"
)

echo [INFO] Committing changes: "%commit_msg%"...
git commit -m "%commit_msg%"

echo [INFO] Pushing to GitHub (main)...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ===================================================
    echo   [SUCCESS] Deployment complete!
    echo   If configured, your Google Site embed will update.
    echo ===================================================
) else (
    echo.
    echo ===================================================
    echo   [ERROR] Push failed. Check your connection / auth.
    echo ===================================================
)

echo.
pause
