# Gemini Clipboard Bridge

A Gemini CLI extension that enables cross-environment clipboard synchronization (SSH, WSL, Docker) using OSC 52 escape sequences.

## Features
- **OSC 52 Support**: Bypasses the Gemini CLI buffer to reach the host terminal's clipboard.
- **Agent Skill**: Allows the AI to "copy to clipboard" autonomously.
- **Slash Command**: Manual copy shortcut via `/cb:copy`.

## Installation
To install the extension, use the fully qualified URL:
```bash
gemini extensions install https://github.com/aaronbronow/gemini-clipboard-bridge
```

## Update
To update an existing installation:
```bash
gemini extensions update gemini-clipboard-bridge
```

Or update all extensions:
```bash
gemini extensions update --all
```

## Usage
Ask Gemini to "copy the last code block to my clipboard" or use the slash command:
```bash
/cb:copy "text to copy"
```

## Sandbox Setup (Docker/Remote)
If you are running Gemini CLI inside a Docker sandbox or a remote environment where the TTY is restricted, you must start a listener on your **host machine** to bridge the gap:

### Option A: Raw Stream (Recommended)
Run this in a separate terminal on your host (WSL/macOS/Linux):
```bash
# Pipes the raw escape sequences directly to your TTY
tail -F .clipboard_bypass > $(tty)
```

### Option B: Named Pipe
Run this in a separate terminal on your host:
```bash
mkfifo .clipboard_pipe
cat .clipboard_pipe > $(tty)
```
