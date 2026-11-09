@echo off
setlocal
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-PODA.ps1" %*
set "PODA_INSTALL_RESULT=%ERRORLEVEL%"
if not "%PODA_INSTALL_RESULT%"=="0" if not defined CI pause
exit /b %PODA_INSTALL_RESULT%
