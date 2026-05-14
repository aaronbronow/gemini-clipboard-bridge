# Gemini Clipboard Bridge Instructions

## Overview
This extension provides a mechanism for Gemini to interact with the system clipboard across remote boundaries (SSH, WSL, containers) using the OSC 52 terminal escape sequence.

## Architecture
- **Skill**: The `clipboard` skill (in `skills/clipboard/SKILL.md`) instructs the AI on how to use the `copy.sh` script.
- **Bypass**: The `copy.sh` script targets `${SSH_TTY:-/dev/tty}` to ensure the escape sequence reaches the host terminal emulator directly, bypassing any internal buffers.

## Constraints
- Only use the `clipboard` skill when explicitly asked to "copy", "save to clipboard", or "sync clipboard".
- Do not attempt to read the clipboard; OSC 52 read support is inconsistently implemented and often disabled for security. This extension is write-only.
