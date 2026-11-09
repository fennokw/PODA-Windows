# PODA Desktop for Windows

PODA is a local-first assistant. This repository builds the Windows x64 desktop app. For the browser-hosted version and shared application source, use [PODA Web](https://github.com/fennokw/PODA-Web).

## Install

1. Download `PODA-Windows-x64` from a successful [desktop workflow](https://github.com/fennokw/PODA-Windows/actions/workflows/desktop.yml). Extract both ZIP layers and keep the app folder together.
2. Install x64 Python 3.12 with the Python Launcher and install Ollama. Open `PODA.exe` and select **Set Up Python Runtime**. Reopen the app when setup finishes.
3. Start Ollama. Use `ollama pull llama3.2:3b` and `ollama pull nomic-embed-text` to install starter chat and embedding models.

The portable build is unsigned. Existing desktop data stays in `%LOCALAPPDATA%\PODA-Windows` and its credentials stay in Windows Credential Manager. Mail supports Classic Outlook and Gmail. Keep PODA open or minimized and Windows awake for Daily Automation.

## Build

Install Node.js 24, Python, and Git. Run the following from the checkout.

```powershell
cd desktop
npm ci --ignore-scripts
npm run package:windows
```

The output is `dist\desktop\PODA-win32-x64\PODA.exe`. The build embeds the pinned PODA Web runtime behind a private backend launcher. The installed app needs no PODA Web checkout or separate server.

For optional Python and pytest execution with Docker Desktop's Linux engine, build the [shared Windows execution image](https://github.com/fennokw/PODA-Web/blob/main/tools/WindowsExecution.dockerfile) as `poda-python:3.12` and set `PODA_WINDOWS_DOCKER=1` before launching PODA.
