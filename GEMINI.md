# Gemini Clipboard Bridge Instructions

## Overview
This extension provides a mechanism for Gemini to interact with the system clipboard across remote boundaries (SSH, WSL, containers) using the OSC 52 terminal escape sequence.

## Project Relationship (Upstream vs. Downstream)
This project (`gemini-clipboard-bridge`) is a **Downstream Implementation** of the core transport logic developed in the **Upstream** project, `agent-bridge-clipboard`.

- **Upstream (`agent-bridge-clipboard`)**: The "Uber" project responsible for developing and testing the core transport mechanisms, multi-platform compatibility (SSH, WSL, Native), bypass fallbacks, and the universal protocol.
- **Downstream (`gemini-clipboard-bridge`)**: This project. It wraps the universal core into a Gemini CLI extension, providing the specific AI Skill and command integrations required for Gemini agents.

## Architecture
- **Skill**: The `gemini-clipboard-bridge` skill (in `skills/gemini-clipboard-bridge/SKILL.md`) instructs the AI on how to use the `copy.sh` script.
- **Commands**: Shortcut commands are provided via the `/cb` prefix (e.g., `/cb:copy`, `/cb:help`).
- **Bypass**: The `copy.sh` script targets `${SSH_TTY:-/dev/tty}` and shared files/pipes to ensure the escape sequence reaches the host terminal emulator.

## Update Process
To synchronize with the latest universal transport logic from upstream:
1. Ensure `agent-bridge-clipboard` is located at `../agent-bridge-clipboard`.
2. Run `make import-upstream`.
3. This will vendor the artifacts, bundle them into the local structure, and automatically apply re-branding (naming, paths, command prefixes).

## Verification
- Use `cd .vendor/agent-bridge-clipboard && ./tests/verify.sh` to run the interactive compatibility matrix test.

## Constraints
- Only use the `clipboard` skill when explicitly asked to "copy", "save to clipboard", or "sync clipboard".
- Do not attempt to read the clipboard; OSC 52 read support is write-only.
