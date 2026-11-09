@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-windows.ps1"
set "PODA_SETUP_RESULT=%ERRORLEVEL%"
echo.
pause
exit /b %PODA_SETUP_RESULT%
