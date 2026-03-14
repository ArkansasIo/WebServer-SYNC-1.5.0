@echo off
setlocal

set SCRIPT_DIR=%~dp0
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-from-github.ps1" -Platform ask

if errorlevel 1 (
  echo.
  echo Install failed.
  pause
  exit /b 1
)

echo.
echo Install completed.
pause
