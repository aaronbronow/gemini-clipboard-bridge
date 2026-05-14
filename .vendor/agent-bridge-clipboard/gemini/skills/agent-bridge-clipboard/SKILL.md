---
name: agent-bridge-clipboard
description: Copies text to the host clipboard using OSC 52 sequences, optimized for SSH and nested terminal environments.
---

# Instructions
When the user wants to copy text, code blocks, or command output to their clipboard:
1. Identify the specific text to be copied.
2. Use `run_shell_command` to execute `scripts/copy.sh "the text to copy"`.
3. The script is designed to bypass environment isolation by writing directly to the active TTY or a bypass channel.
4. Confirm to the user once the text has been successfully copied.

## Sandbox Setup (Action Required by User)
If you are running Gemini CLI inside a Docker sandbox, the agent cannot directly access your host clipboard. You must start a listener on your **host machine** (Windows/WSL terminal) to bridge the gap:

### Option A: Raw Stream (Recommended & Verified)
Run this in a separate terminal on your host (WSL/macOS/Linux). 
*Note: Use `tty` to find your active terminal device (e.g., `/dev/pts/22`).*
```bash
# Pipes the raw escape sequences directly to your TTY
tail -F .clipboard_bypass > $(tty)
```

### Option B: Named Pipe (Lowest Latency)
Run this in a separate terminal on your host:
```bash
mkfifo .clipboard_pipe
cat .clipboard_pipe > $(tty)
```

Once a listener is running, the `copy` command will work seamlessly from within the sandbox.
