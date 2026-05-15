# Gemini Clipboard Bridge Instructions

## Overview
This extension enables Gemini to interact with the system clipboard using the OSC 52 terminal escape sequence. It works across SSH, WSL, and containers.

## Usage Constraints
- Use the `gemini-clipboard-bridge` skill when asked to "copy", "save to clipboard", or "sync clipboard".
- Do not attempt to read the clipboard; OSC 52 is write-only.
- Be concise in your confirmations.
