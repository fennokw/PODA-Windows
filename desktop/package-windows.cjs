'use strict';

const { packager } = require('./package-electron.cjs');
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
    const [python, ...pythonArgs] = process.platform === 'win32' ? ['py.exe', '-3.12'] : ['python3'];
    execFileSync(python, [...pythonArgs, path.join(__dirname, 'stage_backend.py'), backendDir], { stdio: 'inherit' });
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
