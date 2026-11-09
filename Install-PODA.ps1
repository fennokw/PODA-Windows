[CmdletBinding()]
param([switch]$NoLaunch)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    throw 'Install Node.js 24, then run Install-PODA.cmd again.'
}
if (-not (Get-Command py.exe -ErrorAction SilentlyContinue)) {
    throw 'Install 64-bit Python 3.12 with the Python Launcher, then run Install-PODA.cmd again.'
}
& py.exe -3.12 -I -c 'import sysconfig; assert sysconfig.get_platform() == ''win-amd64'', ''PODA requires x64 Python'''
if ($LASTEXITCODE -ne 0) { throw 'PODA requires 64-bit Python 3.12.' }

Push-Location (Join-Path $PSScriptRoot 'desktop')
try {
    & npm.cmd ci --ignore-scripts
    if ($LASTEXITCODE -ne 0) { throw 'Could not install the desktop build dependencies.' }
    & npm.cmd run package:windows
    if ($LASTEXITCODE -ne 0) { throw 'Could not build PODA.' }
}
finally {
    Pop-Location
}

$Bundle = Join-Path $PSScriptRoot 'dist\desktop\PODA-win32-x64'
$App = Join-Path $Bundle 'PODA.exe'
& (Join-Path $Bundle 'resources\backend\setup-windows.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Could not set up the PODA Python runtime.' }

$Desktop = [Environment]::GetFolderPath('DesktopDirectory', 'DoNotVerify')
if (-not $Desktop) { throw 'Windows did not report a Desktop folder.' }
[IO.Directory]::CreateDirectory($Desktop) | Out-Null
$ShortcutPath = Join-Path $Desktop 'PODA.lnk'
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $App
$Shortcut.WorkingDirectory = $Bundle
$Shortcut.Save()
Write-Host "Shortcut created at $ShortcutPath"
if (-not $NoLaunch) { Start-Process -FilePath $App -WorkingDirectory $Bundle }
