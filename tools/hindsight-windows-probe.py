import os
import re
import subprocess
import tempfile
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
    with tempfile.TemporaryFile() as stdout, tempfile.TemporaryFile() as stderr:
        status = subprocess.call(command, env=env, stdout=stdout, stderr=stderr, timeout=timeout, creationflags=flags)
        stdout.seek(0)
        stderr.seek(0)
        print(f"status={status:#x} stdout={stdout.read()[-3000:]!r} stderr={stderr.read()[-3000:]!r}", flush=True)
        if status:
            raise SystemExit(status)

tools = Path(os.environ["SystemRoot"]) / "System32"
identity = subprocess.check_output([str(tools / "whoami.exe"), "/user", "/fo", "csv", "/nh"])
sid = re.search(rb'"(S-1-[0-9-]+)"', identity)[1].decode("ascii")
root = base / "explicit-user"
env = {key: os.environ[key] for key in keys if key in os.environ}
env.update(PG0_HOME=str(root / "database"), PG0_INSTALLATION_DIR=str(root / "postgres"))
(root / "database").mkdir(parents=True)
invoke([str(tools / "icacls.exe"), str(root / "database"), "/grant:r", f"*{sid}:(OI)(CI)F"], env, subprocess.CREATE_NO_WINDOW)
invoke([str(program), "start", "--name", "poda", "--username", "hindsight", "--password", "fixture", "--database", "hindsight"], env, subprocess.CREATE_NO_WINDOW, 40)
invoke([str(program), "stop", "--name", "poda"], env, subprocess.CREATE_NO_WINDOW)
