# Gemini Clipboard Bridge

A Gemini CLI extension that enables cross-environment clipboard synchronization (SSH, WSL, Docker) using OSC 52 escape sequences.

## Features
- **OSC 52 Support**: Bypasses the Gemini CLI buffer to reach the host terminal's clipboard.
- **Agent Skill**: Allows the AI to "copy to clipboard" autonomously.
- **Slash Command**: Manual copy shortcut via `/cb:copy`.

## Installation
```bash
gemini extensions install aaronbronow/gemini-clipboard-bridge
```

## Usage
Ask Gemini to "copy the last code block to my clipboard" or use the slash command:
```bash
/cb:copy "text to copy"
```
