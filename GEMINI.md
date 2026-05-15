# Workspace Memory & Learnings

This file contains local development notes and learnings for the `gemini-clipboard-bridge` project. It is intended for developers working in this repository and is excluded from production extension installations via `.geminiignore`.

## Extension Architecture
- **Context Separation**: Production-facing instructions are in `INSTRUCTIONS.md` (configured in `gemini-extension.json`).
- **Developer Guidance**: Project maintenance and upstream sync details are in `MAINTENANCE.md`.
- **Command Prompts**: Use `<task>` tags in `.toml` command prompts to ensure the agent executes the instruction directly rather than treating it as a conversational suggestion.

## Key Learnings
- **Agent Confusion**: Including complex maintenance instructions in the production context can cause agents to enter "developer mode" unexpectedly. Keep `INSTRUCTIONS.md` lean.
- **Variable Substitution**: In `.toml` commands, `${extensionPath}` is **not** supported; use absolute paths like `~/.gemini/extensions/...`.
- **OSC 52 Constraints**: The transport is write-only. Agents must be instructed not to attempt to read the clipboard.
- **Agent Perspective Shift**: When working inside the extension source directory, the agent adopts a **Developer Persona** (focusing on maintenance, tests, and Makefiles). When the extension is installed elsewhere, the agent adopts a **Production Persona** (focusing only on the instructions in `INSTRUCTIONS.md`). Use `.geminiignore` to hide dev-only files (like this one) to prevent the "Developer Persona" from leaking into production.

## Upstream Synchronization
- Always use `make import-upstream` to pull in core logic from `agent-bridge-clipboard`.
- Branding is automatically applied during the import process via `sed` in the `Makefile`.
