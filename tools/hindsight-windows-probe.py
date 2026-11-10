import os
import subprocess
from pathlib import Path
import pg0

program = next(Path(pg0.__file__).parent.rglob("pg0.exe"), None)
if not program:
    program = next(Path(pg0.__file__).parent.rglob("*.exe"))
base = Path(os.environ["RUNNER_TEMP"]) / "poda-pg0-probe"
keys = ("PATH", "HOME", "USERPROFILE", "SYSTEMROOT", "WINDIR", "COMSPEC", "PATHEXT", "TEMP", "TMP",
        "TMPDIR", "LANG", "LOCALAPPDATA", "APPDATA", "SSL_CERT_FILE", "SSL_CERT_DIR")
win_keys = ("SYSTEMDRIVE", "PROGRAMDATA", "PROGRAMFILES", "PROGRAMFILES(X86)", "PROGRAMW6432",
            "COMMONPROGRAMFILES", "COMMONPROGRAMFILES(X86)", "COMMONPROGRAMW6432",
            "HOMEDRIVE", "HOMEPATH", "USERNAME", "USERDOMAIN", "USERDOMAIN_ROAMINGPROFILE",
            "COMPUTERNAME", "OS", "PROCESSOR_ARCHITECTURE", "NUMBER_OF_PROCESSORS", "SESSIONNAME")
def invoke(command, env, flags, timeout=20):
    try:
        result = subprocess.run(command, env=env, capture_output=True, timeout=timeout, creationflags=flags)
        print(f"status={result.returncode:#x} stdout={result.stdout[-3000:]!r} stderr={result.stderr[-3000:]!r}", flush=True)
    except subprocess.TimeoutExpired:
        print("Timeout", flush=True)

for label, keys_for_run, flags in (
    ("poda", keys, subprocess.CREATE_NO_WINDOW),
    ("full-env", tuple(os.environ), subprocess.CREATE_NO_WINDOW),
    ("windows-vars", keys + win_keys, subprocess.CREATE_NO_WINDOW),
    ("console", keys + win_keys, 0),
):
    print(label, flush=True)
    root = base / label
    env = {key: os.environ[key] for key in keys_for_run if key in os.environ}
    env.update(PG0_HOME=str(root / "database"), PG0_INSTALLATION_DIR=str(root / "postgres"))
    invoke([str(program), "start", "--name", "poda", "--username", "hindsight", "--password", "fixture", "--database", "hindsight"], env, flags)
    for name in ("initdb.exe", "postgres.exe"):
        for child in (root / "postgres").rglob(name):
            print(child.relative_to(root), flush=True)
            invoke([str(child), "--version"], env, flags)
    invoke([str(program), "stop", "--name", "poda"], env, flags)
