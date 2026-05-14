---
name: clipboard
description: Use this skill when the user wants to copy text to their system clipboard across SSH/WSL.
---
# Clipboard Skill

Use this skill when the user asks to "copy" or "save to clipboard". This handles the OSC 52 escape sequences required to bypass the agent buffer and reach the host terminal's clipboard.

## Usage
The skill uses the `copy.sh` script located in the `scripts/` directory.

### Example
If the user says "Copy that last function to my clipboard", you should:
1. Extract the function code.
2. Pipe it to `scripts/copy.sh`.
