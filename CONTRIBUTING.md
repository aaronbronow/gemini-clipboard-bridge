# Contributor Workflow: Setting Up & Verifying

To contribute to `gemini-clipboard-bridge`, follow these steps to set up your environment, synchronize logic, and verify the extension locally.

## 1. Environment Setup
Ensure you have the following prerequisites:
- **Gemini CLI** installed.
- **Upstream Repository**: You must have `agent-bridge-clipboard` cloned as a sibling directory to this project.

```bash
# Clone the projects
git clone https://github.com/aaronbronow/agent-bridge-clipboard
git clone https://github.com/aaronbronow/gemini-clipboard-bridge

# Your directory structure should look like this:
# /dev/
#   ├── agent-bridge-clipboard/
#   └── gemini-clipboard-bridge/
```

## 2. Synchronize Upstream Logic
This project uses a modular "hybrid distribution" model. It vendors the core transport logic from the upstream `dist/` directory.

```bash
# First, build the upstream project to generate modular artifacts
cd ../agent-bridge-clipboard
make build

# Return to this project and import the latest skill logic
cd ../gemini-clipboard-bridge
make import-upstream
```

## 3. Verify Files & Branding
The `import-upstream` target automatically applies Gemini-specific branding and fixes pathing. Use the built-in integration tests to verify the project state:

```bash
make test
```
*Expected output: `All integration tests passed!`*

## 4. Run Locally in a Sandbox
To test the extension logic within an agent session without installing it globally, use the Gemini CLI's **Sandbox Mode**.

```bash
# Start a sandbox session in the current directory
gemini --sandbox .
```

### Verification Steps inside the Agent:
1.  **Check Context**: Ask the agent, "What extension instructions are loaded?" It should summarize the content of `INSTRUCTIONS.md`.
2.  **Test Slash Command**: Run `/cb:help` to see the available commands.
3.  **Test Copy Action**: Run `/cb:copy "Hello from Sandbox"` and verify that your host clipboard is updated.
4.  **Test AI Skill**: Ask the agent, "Copy the current date to my clipboard." It should use the `gemini-clipboard-bridge` skill to execute the `copy.sh` script.

## 5. Submitting Changes
- **Logic Changes**: If you need to modify the transport logic (e.g., `copy.sh`), do it in the **upstream** project and then re-run `make import-upstream` here.
- **Gemini Metadata**: Changes to `gemini-extension.json`, `INSTRUCTIONS.md`, or the `/cb` commands should be made directly in this repository.

## 7. Key Extension Constraints & Best Practices
When contributing to this extension, adhere to these technical constraints identified through development:

- **Agent Confusion**: Keep `INSTRUCTIONS.md` lean. It should only contain production-facing usage constraints. Complex maintenance or development instructions must remain in `CONTRIBUTING.md` or `MAINTENANCE.md` to prevent agents from unexpectedly entering "developer mode" during user sessions.
- **No `${extensionPath}` Support**: In `.toml` command files, `${extensionPath}` is **not** supported by the Gemini CLI.
- **Path Resolution in Commands**: Shell execution macros (`!{}`) in `.toml` files resolve relative to the user's current working directory, not the extension directory. To ensure scripts are always found regardless of where the user is, use absolute, shell-expandable paths: `~/.gemini/extensions/gemini-clipboard-bridge/...`.
- **Agent Perspective Shift**: Use `.geminiignore` to hide development-only files (like `Makefile`, `tests/`, `GEMINI.md`, and `CONTRIBUTING.md`). This ensures the agent maintains a **Production Persona** (focusing only on user instructions) when the extension is installed in a user's environment, rather than adopting a **Developer Persona**.
- **OSC 52 Constraints**: The transport is write-only. Never instruct the agent to attempt to read from the clipboard.

## 8. Releasing
Every release **must** include the standard installation instructions in the release notes:
- **Install Command**: Use a fully qualified URL: `gemini extensions install https://github.com/aaronbronow/gemini-clipboard-bridge`.
- **Update Command**: `gemini extensions update gemini-clipboard-bridge`.
