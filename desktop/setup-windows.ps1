[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

function Run-Checked {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Executable exited with code $LASTEXITCODE." }
}

$Requirements = Join-Path $PSScriptRoot 'requirements.txt'
$Data = if ($env:PODA_DATA_DIR) { $env:PODA_DATA_DIR } else { Join-Path $env:LOCALAPPDATA 'PODA-Windows' }
$Data = [IO.Path]::GetFullPath($Data)
$Version = (Get-FileHash -Algorithm SHA256 -LiteralPath $Requirements).Hash.Substring(0, 16).ToLowerInvariant()
$RuntimeParent = Join-Path $Data 'desktop-runtime'
$Runtime = Join-Path $RuntimeParent $Version
$Python = Join-Path $Runtime 'Scripts\python.exe'
$Ready = Join-Path $Runtime '.ready'
[IO.Directory]::CreateDirectory($RuntimeParent) | Out-Null
$Lock = [IO.File]::Open((Join-Path $RuntimeParent 'setup.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
try {
    if ((Test-Path -LiteralPath $Ready -PathType Leaf) -and (Test-Path -LiteralPath $Python -PathType Leaf)) {
        Write-Host 'PODA runtime is ready. Open PODA Windows again.'
        exit 0
    }
    $Launcher = Get-Command py.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $Launcher) { throw 'Install 64-bit Python 3.12 from python.org with the Python Launcher option enabled, then run Setup PODA again.' }

    Run-Checked $Launcher.Source @('-3.12', '-I', '-c', 'import sysconfig; assert sysconfig.get_platform() == ''win-amd64'', ''PODA requires x64 Python''')
    if (Test-Path -LiteralPath $Ready) { Remove-Item -LiteralPath $Ready }
    Run-Checked $Launcher.Source @('-3.12', '-I', '-m', 'venv', $Runtime)
    Run-Checked $Python @('-I', '-m', 'pip', 'install', '--only-binary=:all:', '--disable-pip-version-check', '-r', $Requirements)
    Run-Checked $Python @('-I', '-c', 'import fastapi, uvicorn, win32cred, pythoncom, open3d; from sqlcipher3 import dbapi2; from zoneinfo import ZoneInfo; assert dbapi2.connect('':memory:'').execute(''PRAGMA cipher_version'').fetchone(); ZoneInfo(''America/New_York'')')
    [IO.File]::WriteAllText($Ready, 'ready')
    Write-Host 'PODA runtime is ready. Open PODA Windows again.'
}
finally {
    $Lock.Dispose()
}
