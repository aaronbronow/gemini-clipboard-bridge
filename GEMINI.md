# Workspace Memory & Learnings

Local development notes for `gemini-clipboard-bridge`.

## Architecture
- **Production Context**: `INSTRUCTIONS.md` contains lean, production-only usage rules.
- **Developer Context**: `GEMINI.md` and `CONTRIBUTING.md` (ignored by `.geminiignore`) provide maintenance guidance.
- **Upstream Sync**: Use `make import-upstream` to pull core logic from `agent-bridge-clipboard`.

## Technical Constraints
- **OSC 52**: Write-only. Do not attempt to read the clipboard.
- **Path Resolution**: `${extensionPath}` is **not** supported in `.toml` commands. Use absolute paths: `~/.gemini/extensions/gemini-clipboard-bridge/...`.
- **Command Prompts**: Use `<task>` tags in `.toml` files to ensure direct execution.
- **Environment Isolation**: In sandboxes (Docker), use the `.clipboard_bypass` listener on the host.
