---
name: gemini-clipboard-bridge
description: Copies text to the host clipboard using OSC 52 sequences, optimized for SSH and nested terminal environments.
---

# Instructions
When the user wants to copy text, code blocks, or command output to their clipboard:
1. Identify the specific text to be copied.
2. Use `run_shell_command` to execute `scripts/copy.sh "the text to copy"`.
3. The script is designed to bypass environment isolation by writing directly to the active TTY or a bypass channel.
4. Confirm to the user once the text has been successfully copied.
