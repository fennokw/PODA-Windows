@echo off
setlocal
cd /d "%~dp0"
if not defined PODA_DATA_DIR set "PODA_DATA_DIR=%LOCALAPPDATA%\PODA-Windows"
for /f %%I in ('powershell.exe -NoLogo -NoProfile -Command "(Get-FileHash -LiteralPath requirements.txt -Algorithm SHA256).Hash.Substring(0,16).ToLowerInvariant()"') do set "PODA_RUNTIME_VERSION=%%I"
if not defined PODA_RUNTIME_VERSION exit /b 1
set "PODA_RUNTIME=%PODA_DATA_DIR%\desktop-runtime\%PODA_RUNTIME_VERSION%"
if not exist "%PODA_RUNTIME%\.ready" (
    echo Run Setup-PODA.cmd first.
    exit /b 1
)
set "PODA_DB_ENCRYPTION=required"
set "PYTHONUTF8=1"
echo Open http://127.0.0.1:8787 once the server is ready.
"%PODA_RUNTIME%\Scripts\python.exe" -m poda_app.server
