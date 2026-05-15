# Maintenance Instructions

## Project Relationship (Upstream vs. Downstream)
This project (`gemini-clipboard-bridge`) is a **Downstream Implementation** of the core transport logic developed in the **Upstream** project, `agent-bridge-clipboard`.

- **Upstream (`agent-bridge-clipboard`)**: The "Uber" project responsible for developing and testing the core transport mechanisms, multi-platform compatibility (SSH, WSL, Native), bypass fallbacks, and the universal protocol.
- **Downstream (`gemini-clipboard-bridge`)**: This project. It wraps the universal core into a Gemini CLI extension, providing the specific AI Skill and command integrations required for Gemini agents.

## Implementation Details
The production-facing instructions are located in `INSTRUCTIONS.md`. This file is loaded by Gemini CLI when the extension is active. Keep it focused on usage and constraints.

## Update Process
To synchronize with the latest universal transport logic from upstream:
1. Ensure `agent-bridge-clipboard` is located at `../agent-bridge-clipboard`.
2. Run `make import-upstream`.
3. This will vendor the artifacts, bundle them into the local structure, and automatically apply re-branding (naming, paths, command prefixes).

## Verification
- Use `cd .vendor/agent-bridge-clipboard && ./tests/verify.sh` to run the interactive compatibility matrix test.
- Use `make test` to run the local integration tests.

## Distribution & Ignoring
- **.geminiignore**: We ignore the `.vendor/` directory to keep extension installations lean. 
- **Persistence**: We intentionally **do not** ignore the `Makefile` or `tests/`. This ensures that AI agents can always perform integration tests and synchronize with upstream logic without manual intervention or configuration overrides.
- **Release Boilerplate**: Every release **must** include the standard "Installation Instructions" boilerplate in the release notes. 
  - **Install Command**: Ensure the instructions use a fully qualified URL (e.g., `gemini extensions install https://github.com/user/gemini-clipboard-bridge`). repo-only names are not supported.
  - **Update Command**: Always include instructions for updating existing installations: `gemini extensions update --all` or `gemini extensions update gemini-clipboard-bridge`.

## Troubleshooting & Command Development
### "No such file or directory" in commands
In Gemini CLI, shell execution macros (`!{}`) in `.toml` command files resolve relative to the **current workspace directory** by default. 

**Important Note on Variable Substitution:**
According to the official [Custom Commands Documentation](https://geminicli.com/docs/cli/custom-commands#executing-shell-commands), `${extensionPath}` is only supported for variable substitution in `gemini-extension.json` and `hooks/hooks.json`. It is **not** supported in `.toml` command files, where `{{args}}` is the only variable currently supported for interpolation within shell execution macros (`!{...}`).

To ensure extension scripts are found regardless of the user's location in a `.toml` command, you must use a shell-expandable absolute path (e.g., `!{~/.gemini/extensions/gemini-clipboard-bridge/path/to/script.sh}`). This was standardized in v1.0.3.
