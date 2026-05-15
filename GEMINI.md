# Gemini Clipboard Bridge Instructions

## Overview
This extension provides a mechanism for Gemini to interact with the system clipboard across remote boundaries (SSH, WSL, containers) using the OSC 52 terminal escape sequence.

## Architecture
- **Skill**: The `gemini-clipboard-bridge` skill (in `skills/gemini-clipboard-bridge/SKILL.md`) instructs the AI on how to use the `copy.sh` script.
- **Commands**: Shortcut commands are provided via the `/cb` prefix (e.g., `/cb:copy`, `/cb:help`).
- **Bypass**: The `copy.sh` script targets `${SSH_TTY:-/dev/tty}` and shared files/pipes to ensure the escape sequence reaches the host terminal emulator.

## Constraints
- Only use the `clipboard` skill when explicitly asked to "copy", "save to clipboard", or "sync clipboard".
- Do not attempt to read the clipboard; OSC 52 read support is write-only.

## Maintenance
For project maintenance, upstream synchronization, and contributor guidelines, see `MAINTENANCE.md`.
