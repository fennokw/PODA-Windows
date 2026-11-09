'use strict';

const { packager } = require('@electron/packager');
const { copyFileSync, mkdirSync, mkdtempSync, rmSync } = require('node:fs');
const { execFileSync } = require('node:child_process');
const { tmpdir } = require('node:os');
const path = require('node:path');
const { devDependencies, version } = require('./package.json');

async function build() {
  const root = path.resolve(__dirname, '..');
  const stage = mkdtempSync(path.join(tmpdir(), 'poda-desktop-'));
  try {
    const appDir = path.join(stage, 'app');
    const backendDir = path.join(stage, 'backend');
    mkdirSync(appDir);
    mkdirSync(backendDir);
    for (const file of ['main.cjs', 'package.json']) {
      copyFileSync(path.join(__dirname, file), path.join(appDir, file));
    }
    const stageBackend = String.raw`
import shutil
import sys
from pathlib import Path
from tools.release_guard import ROOT, audit, shipping_paths

target = Path(sys.argv[1])
files = shipping_paths()
errors = audit(files)
if errors:
    raise SystemExit("\n".join(errors))
for file in files:
    relative = file.relative_to(ROOT)
    if relative.parts[0] != "poda_app" and relative.as_posix() not in {
        "Setup-PODA.cmd", "setup-windows.ps1", "requirements.txt", "PODA_VERSION.txt", "LICENSE", "LICENSE-PODA"
    }:
        continue
    destination = target / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(file, destination)
`;
    execFileSync(process.platform === 'win32' ? 'python' : 'python3', ['-c', stageBackend, backendDir], { cwd: root, stdio: 'inherit' });
    const output = await packager({
      dir: appDir, out: path.join(root, 'dist', 'desktop'), overwrite: true,
      name: 'PODA', platform: 'win32', arch: 'x64', electronVersion: devDependencies.electron,
      appVersion: version, asar: true, prune: false,
      win32metadata: { CompanyName: 'PODA contributors', ProductName: 'PODA Windows', FileDescription: 'PODA Windows' },
      extraResource: [backendDir],
    });
    for (const directory of output) console.log(path.join(directory, 'PODA.exe'));
  } finally {
    rmSync(stage, { recursive: true, force: true });
  }
}

build().catch(error => { console.error(error); process.exitCode = 1; });
