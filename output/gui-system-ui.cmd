@echo off
setlocal

set SCRIPT_DIR=%~dp0
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%gui-system-ui.ps1"

if errorlevel 1 (
  echo.
  echo GUI launch failed.
  pause
  exit /b 1
)
