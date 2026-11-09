# PODA Windows security

PODA serves its UI and API on loopback. The Electron renderer uses context isolation and a sandbox. The desktop backend requires an Electron-owned token and uses a local session cookie and origin checks. The application stores the live database with SQLCipher. Windows Credential Manager stores the database key, backup key, and connector credentials under the signed-in user's profile.

File tools require user-granted folders. Writes and execution require approval or an applicable automation grant. The optional Docker Desktop runner mounts the approved working folder, disables container networking, and bounds the run time. Software harnesses are trusted local executables installed and enabled by the user.

PODA uses Ollama locally. Gmail and Notion can connect to their designated services. Classic Outlook can sync through its own configured account and may display Windows or Outlook security prompts. PODA's offline setting pauses its connector operations.

Report a suspected vulnerability privately using [GitHub's vulnerability reporting page](https://github.com/fennokw/PODA-Windows/security). Include the build ID and reproduction steps using synthetic data.
