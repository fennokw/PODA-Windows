# PODA Windows

PODA is a local-first assistant with an Electron desktop app for Windows. This edition uses the same chat, knowledge graph, workflow approvals, planning, memory, Notion, email, and Daily Automation features as the [upstream PODA project](https://github.com/fennokw/PODA).

## Install

1. Install [x64 Python 3.12](https://www.python.org/downloads/windows/) with the Python Launcher, and [Ollama for Windows](https://ollama.com/download/windows).
2. Download the `PODA-Windows-x64` artifact from a successful [Windows desktop build](https://github.com/fennokw/PODA-Windows/actions/workflows/desktop.yml), then extract both ZIP layers. Keep the contents of the app folder together.
3. Open `PODA.exe`, select **Set Up Python Runtime**, and reopen the app after setup finishes. The current build is unsigned.
4. Start Ollama. To install starter chat and embedding models, use `ollama pull llama3.2:3b` and `ollama pull nomic-embed-text`, or choose installed models in PODA's System screen.

The build targets Windows 10 and 11 on x64. Keep PODA open or minimized and Windows awake for Daily Automation. Closing the app stops its local backend and scheduler.

## Platform integrations

| Feature | Windows implementation |
| --- | --- |
| Chat, memory, projects, Notion and automations | The same application and workflows as upstream, with local Ollama and Windows time-zone data |
| Credentials and backups | Windows Credential Manager, SQLCipher and AES-GCM backups under `%LOCALAPPDATA%\PODA-Windows` |
| Mail | Classic Outlook profiles or direct Gmail with an app password. The new Outlook client lacks the Outlook Object Model used here. |
| Model compatibility | Measured physical RAM, disk space and dedicated VRAM reported by DXGI |
| Folder access | User-granted folders with separate read, edit and execution permissions |
| Python and pytest tools | Optional Docker Desktop Linux-container isolation for approved runs |
| Software skills | Windows-native CLI harness discovery and execution, subject to the installed harness's Windows support |

In **Mail**, open classic Outlook and select the accounts PODA can access. Editing and sending are separate opt-ins. Gmail can connect directly without Outlook. Outlook reports when it accepts a send command. Delivery depends on the mail provider.

In **Memory Viewer**, open **Knowledge relationships → Find memories to review**. Review exact source quotes before committing facts. In **Ask → Recent chats**, reopen a conversation to recover approvals and action receipts. See the [desktop and knowledge guide](docs/DESKTOP_AND_KNOWLEDGE.md) for the workflow and transcript review.

## Code execution

For the isolated runner, install [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) and start its Linux engine. From the checkout, prepare the local image and launch PODA from the same PowerShell session.

```powershell
docker build -f tools/WindowsExecution.dockerfile -t poda-python:3.12 .
$env:PODA_WINDOWS_DOCKER = '1'
& 'C:\path\to\PODA.exe'
```

Grant edit and execute access to a specific project folder in PODA. An approved command runs with that folder mounted, networking disabled, and an ephemeral temporary directory. Add any project-specific Python dependencies to a trusted local image with the same tag before running its tests.

## Build from source

From the checkout, run `Setup-PODA.cmd` and `Start-PODA.cmd` to use the local web app. To build the desktop package, install Node.js 24 and run these commands.

```powershell
cd desktop
npm ci --ignore-scripts
npm run package:windows
```

The output is `dist\desktop\PODA-win32-x64\PODA.exe`. The workflow also tests Windows Credential Manager, SQLCipher, native hardware detection, backend startup, and workflow and graph behavior using synthetic data.

The original PODA source is distributed under its MIT license in [LICENSE-PODA](LICENSE-PODA). See [LICENSE](LICENSE) for this repository's Apache 2.0 license.
