# PODA for Windows

PODA is a local-first assistant for chat, memory, mail, projects, and automations. This repository contains the full Windows x64 desktop application.

## Install from source

1. Clone this repository or download and extract its source ZIP. Install Node.js 24, x64 Python 3.12 with the Python Launcher, and Ollama for local models.
2. Double-click `Install-PODA.cmd`. The command builds `PODA.exe` from this folder, sets up the Python runtime, creates a PODA shortcut on your Desktop, and opens the app.
3. Keep this folder in place so the shortcut can find the app. Rerun the command after pulling updates or editing the code.

Start Ollama and run `ollama pull llama3.2:3b` and `ollama pull nomic-embed-text` for starter chat and embedding models. PODA stores desktop data in `%LOCALAPPDATA%\PODA-Windows` and uses Windows Credential Manager. Mail supports Classic Outlook and Gmail.

## Source layout

- `poda_app/` contains the application API, UI, agent, memory, and integrations.
- `desktop/` contains the Electron launcher, runtime setup, and packager.
- `tests/` contains the application regression tests.

A prebuilt unsigned x64 package is available in the [desktop workflow artifacts](https://github.com/fennokw/PODA-Windows/actions/workflows/desktop.yml). The separate browser edition is available in [PODA Web](https://github.com/fennokw/PODA-Web).

For optional Python and pytest execution with Docker Desktop's Linux engine, build [the included image](tools/WindowsExecution.dockerfile) as `poda-python:3.12` and set `PODA_WINDOWS_DOCKER=1` before launching PODA.

Daily Automation resolves email event dates against the original send time, then verifies authorized Notion additions. To use the same read-only scheduling tools from an MCP client, run `python -m poda_app.scheduling.mcp` over stdio from the source folder with the PODA Python environment.

Use **Personalize → Memory search with Hindsight** to install and enable the local search engine. Setup uses an installed Ollama chat model and the PODA embedding model. Hindsight keeps a derived index in the app's data folder. **Add-ons** contains the downloadable program catalog and saved skills. Program tools require a separate trust opt-in and per-tool enable switch. **Developer mode** in the toolbar reveals technical diagnostics.

In Chat, choose **Attach files**, drop files into the chat, or paste a screenshot. Files are shared with that message only. PODA can inspect source ZIPs and text-based PDFs and return edited copies. A revised PDF uses PODA’s document layout. To read images, install a local vision model such as `qwen3-vl:4b` from **System → Model installer and profile selection**.
