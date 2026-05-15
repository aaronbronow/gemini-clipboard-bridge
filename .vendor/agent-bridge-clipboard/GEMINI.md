# Project Instructions: Agent Bridge Clipboard

## Project Architecture
This repository serves as the **Upstream** "Uber" project for developing universal clipboard synchronization skills across multiple AI agent ecosystems (Gemini, Claude, etc.).

- **Upstream (`agent-bridge-clipboard`)**: Responsible for core transport logic, cross-environment compatibility (SSH, WSL, Native), and the universal protocol.
- **Downstream (`gemini-clipboard-bridge`)**: A specific implementation and bridge for Gemini CLI skills.

## Clipboard Testing Protocol
The verification process for the `tests/COMPATIBILITY.md` matrix is handled **strictly** by the `tests/verify.sh` script.

### Protocol Rules
- **Interactive Requirement**: The script is interactive and **must** be run in a live, interactive subshell (e.g., `gemini --shell` or a direct terminal). It will exit immediately if executed as a non-interactive command (especially in Sandbox mode).
- **Mandatory Metadata**: You MUST provide client metadata via environment variables for accurate matrix reporting.
- **Workflow**:
  ```bash
  CLIENT_OS="Windows" CLIENT_TERM="Windows Terminal" AGENT_MODE="Default" ./tests/verify.sh
  ```
- **Manual testing bypass**: Do NOT attempt to run manual tests or individual commands for the purpose of updating the matrix. Use the script to ensure consistent logging.
- **Verification**: When prompted by the script, paste your clipboard content (Ctrl+V/Cmd+V) to verify the result.
- **Reset**: Use `tests/verify.sh --clear` to reset the matrix to its baseline state.

### Learnings & Patterns
- **SSH Bypass**: We have confirmed that writing directly to the `SSH_TTY` device (e.g., `/dev/pts/0`) is the most reliable way to bypass Gemini CLI subshell capture in remote environments.
- **Reporting**: The compatibility matrix now distinguishes between the **User Environment** (host metadata) and **Agent Environment** (runtime context/TTY).
- **False Positives**: The script now performs a robust clipboard clear before every test case. In WSL2 environments where OSC 52 is captured, automated clearing must use fallbacks like `clip.exe` to prevent stale data from compromising results.

### Compatibility Matrix Rules
- **Positioning**: The Markdown table **must** be the final element in `tests/COMPATIBILITY.md`.
- **Columns**: User Environment, Agent Environment, Agent Mode, Connection, Method, Status.

## Current Focus
- **VS Code Terminal Testing**: Investigate and verify OSC 52 support within the VS Code integrated terminal, specifically handling the security gating (`terminal.integrated.allowOsc52`).
- **SSH Bypass Testing**: The next priority is testing the `SSH_TTY` bypass logic on remote environments (e.g., `ubuntu-dev`).
- **OSC 52 Troubleshooting**: We've confirmed that standard OSC 52 escapes are captured by the Gemini CLI subshell in local WSL2/xterm-256color environments. Testing via a direct SSH TTY is the next step to verify if we can bypass this capture.
- **WSL Success**: We have confirmed `clip.exe` and `powershell.exe` as successful fallback methods for local WSL2 sessions.

## Sandboxing on ARM/WSL2
If you encounter an `Exec format error` when running `gemini --sandbox` on an ARM64 host (like Surface Pro 9/11 or Apple Silicon), it is because the official sandbox image is `amd64`.

### Solution: Build a local ARM image
1. **Build the image**:
   ```bash
   docker build -t gemini-sandbox-arm64 -f .gemini/sandbox.Dockerfile .
   ```
2. **Configure Gemini to use it**:
   Add this to your `.env` or run it in your shell:
   ```bash
   export GEMINI_SANDBOX_IMAGE="gemini-sandbox-arm64"
   ```

## Sandbox Clipboard Limitations & Bypasses
Direct clipboard access from the Docker sandbox is restricted by environment isolation and the headless nature of the container.

### Findings
- **Tooling Failure**: Traditional tools like `xsel` and `wl-clipboard` fail because the sandbox lacks an X11 or Wayland display server.
- **OSC 52 Capture**: Standard OSC 52 escape sequences sent to `stdout` are captured and neutralized by the Gemini CLI subshell buffer, preventing them from reaching the host terminal.
- **TTY Absence**: Writing to `/dev/tty` fails within the sandbox as no TTY is allocated for the agent's shell.

### Sandbox Bypass Protocols (Verified)
The following protocols bridge the sandbox and host clipboard by using shared workspace files as signaling channels. These mechanisms are abstracted by `copy.sh` and verified via `tests/verify.sh`.

#### 1. SSH TTY Redirection (Remote/Background)
- **Status**: **SUCCESS** - Most reliable for remote environments.
- **Mechanism**: Writing directly to the `$SSH_TTY` device (e.g., `/dev/pts/0`) bypasses Gemini CLI subshell capture, even from background processes.
- **Command**: `printf '\e]52;c;... \a' > $SSH_TTY`

#### 2. Named Pipe (FIFO)
- **Status**: **SUCCESS** - Preferred for low-latency local sandboxes.
- **Host Listener**: `while true; do cat .clipboard_pipe; done > $(tty)`
- **Mechanism**: The system writes OSC 52 escape sequences to `.clipboard_pipe`.

#### 3. File-Based signaling
- **Status**: **SUCCESS** - Robust fallback for local sandboxes.
- **Host Listener**: `tail -F .clipboard_bypass > $(tty) &` (Can be run in background of same session).
- **Mechanism**: The system writes OSC 52 escape sequences to `.clipboard_bypass`.

### Headless Verification Protocol
For testing in non-interactive environments (e.g., background tasks, `run_shell_command`), use the Headless Mode via the `Makefile`.

1. **Initiate Test (Agent)**: 
   ```bash
   make headless METHOD=<method_name>
   ```
   *Common methods: `osc52-ssh`, `osc52-stdout`, `bypass-file`.*
2. **Retrieve Token (User)**: The script generates a unique token and attempts to write it to the clipboard.
3. **Validate Result (User)**:
   ```bash
   make validate TOKEN=<paste_clipboard_here>
   ```
   *A mismatch or empty paste indicates capture or transport failure.*

### One-off Prompt Protocol (gemini -p)
To use the clipboard bridge with one-off prompts, you must elevate the agent's permission mode. Non-interactive mode defaults to a read-only policy that blocks shell tools.

- **Command**: `gemini -p "copy 'it worked!' to the clipboard" --yolo`
- **Result**: In remote sessions, this triggers the `SSH_TTY` bypass and updates your host clipboard natively.

## Current Focus

#### Bridge Logic (`copy.sh`)
The `copy.sh` bridge prioritizes execution as follows:
1. **Native Tools**: Uses `clip.exe` (WSL) or `pbcopy` (macOS) if available in the local environment.
2. **SSH TTY Bypass**: Writes to `$SSH_TTY` (e.g., `/dev/pts/0`) for remote background/headless reliability.
3. **Direct TTY**: Writes to `/dev/tty` (effective for local interactive sessions).
4. **Bypass Channels**: Writes to both `.clipboard_bypass` and `.clipboard_pipe` (required for Docker Sandboxes).
5. **Stdout**: Final fallback to the primary output stream.

## Environment Notes
- **WSL2 (Ubuntu 24.04)**: Requires `clip.exe` or `powershell.exe` for reliable clipboard access due to subshell output capture.
- **ARM64 Compatibility**: Use the local Dockerfile in `.gemini/` to build a native sandbox image. This image includes `xsel` and `wl-clipboard` to support built-in clipboard commands like `/copy`.
