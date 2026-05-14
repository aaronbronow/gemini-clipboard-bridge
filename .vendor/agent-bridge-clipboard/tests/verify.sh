#!/bin/bash
# Clipboard Compatibility Verifier

# --- Configuration ---
MATRIX_FILE="tests/COMPATIBILITY.md"

clear_matrix() {
    echo "Clearing $MATRIX_FILE..."
    cat <<EOF > "$MATRIX_FILE"
# Environment Compatibility Matrix

## Notes
- **Windows Terminal:** Requires OSC 52 enabled in settings.
- **TMUX:** May require \`set -s set-clipboard on\` in \`.tmux.conf\`.

Use \`tests/verify.sh\` to populate this matrix.

| User Environment | Agent Environment | Agent Mode | Connection | Method | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
EOF
    echo "Matrix cleared."
}

if [[ "$1" == "--clear" ]]; then
    clear_matrix
    exit 0
fi

clear_clipboard() {
    # OSC 52 Clear (Standard)
    if [ -n "$SSH_TTY" ]; then
        printf '\e]52;c;AA==\a' > "$SSH_TTY"
    else
        printf '\e]52;c;AA==\a' > /dev/tty
    fi

    # WSL Fallback
    if grep -qi microsoft /proc/version 2>/dev/null; then
        if command -v clip.exe >/dev/null; then
            echo -n "" | clip.exe
        fi
    fi

    # macOS Fallback
    if [[ "$OSTYPE" == "darwin"* ]] && command -v pbcopy >/dev/null; then
        echo -n "" | pbcopy
    fi
    
    sleep 0.5
}

echo "--- Clipboard Compatibility Tester ---"
echo "Machine: $(hostname)"
echo "OS: $(uname -srm)"
echo "Client: ${CLIENT_OS:-Unknown} / ${CLIENT_TERM:-Unknown}"
echo "TTY: $(tty)"
echo "SSH_TTY: $SSH_TTY"
echo "TERM: $TERM"
echo "-----------------------------------"

# Detection
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then IS_WSL=true; fi
IS_MACOS=false
if [[ "$OSTYPE" == "darwin"* ]]; then IS_MACOS=true; fi

test_copy() {
    local category=$1
    local label=$2
    local cmd=$3
    local expected=$4
    local full_label="[$category] $label"
    
    echo "Clearing clipboard..."
    clear_clipboard

    echo "Testing $full_label..."
    eval "$cmd"
    
    echo -n "Please PASTE your clipboard content (Ctrl+V/Cmd+V) and press Enter: "
    read -r pasted
    
    if [ "$pasted" == "$expected" ]; then
        status="SUCCESS"
        echo "[$status] Clipboard matches: '$pasted'"
    else
        status="FAILURE"
        echo "[$status] Expected '$expected', but got '$pasted'"
    fi
    
    # --- Logging Logic ---
    local agent_os=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2 || uname -s)
    
    local connection="Local"
    [ -n "$SSH_TTY" ] && connection="SSH"
    
    local multiplexer=""
    [ -n "$TMUX" ] && multiplexer=", tmux"
    
    # Mode detection
    local mode="Outside CLI"
    if [ "$GEMINI_CLI" = "1" ]; then
        mode="${GEMINI_MODE:-Default}"
        # Heuristic for sandbox if not explicitly provided
        if [ -z "$GEMINI_MODE" ] && env | grep -qiE "SANDBOX|DOCKER|KUBERNETES"; then
            mode="Sandbox"
        fi
    fi
    
    local user_env="${CLIENT_OS:-Unknown} / ${CLIENT_TERM:-Unknown}"
    local agent_env="${agent_os} (${TERM} on $(tty)${multiplexer})"
    
    printf "| %s | %s | %s | %s | %s | %s |\n" \
        "$user_env" "$agent_env" "$mode" "$connection" "$full_label" "$status" >> tests/COMPATIBILITY.md
}

# --- OSC 52 Category ---
test_copy "OSC 52" "Direct stdout" "printf '\e]52;c;dGVzdC1vc2M1Mi1zdGRvdXQ=\a'" "test-osc52-stdout"
test_copy "OSC 52" "Direct /dev/tty" "printf '\e]52;c;dGVzdC1vc2M1Mi10dHk=\a' > /dev/tty" "test-osc52-tty"

if [ -n "$SSH_TTY" ]; then
    test_copy "OSC 52" "Targeted SSH_TTY ($SSH_TTY)" "printf '\e]52;c;dGVzdC1vc2M1Mi1zc2g=\a' > $SSH_TTY" "test-osc52-ssh"
fi

if [ -n "$TMUX" ]; then
    test_copy "OSC 52" "TMUX Wrapped" "printf '\ePtmux;\e\e]52;c;dGVzdC1vc2M1Mi10bXV4\a\e\\' > ${SSH_TTY:-/dev/tty}" "test-osc52-tmux"
fi

# --- WSL Category ---
if [ "$IS_WSL" = true ]; then
    CLIP_EXE=$(command -v clip.exe || echo "/mnt/c/Windows/System32/clip.exe")
    if [ -f "$CLIP_EXE" ] || command -v clip.exe >/dev/null; then
        test_copy "WSL" "clip.exe pipe" "echo -n 'test-clip-exe' | \"$CLIP_EXE\"" "test-clip-exe"
    fi
    
    POWERSHELL_EXE=$(command -v powershell.exe || echo "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe")
    if [ -f "$POWERSHELL_EXE" ] || command -v powershell.exe >/dev/null; then
        test_copy "WSL" "powershell.exe" "echo -n 'test-powershell' | \"$POWERSHELL_EXE\" -Command Set-Clipboard" "test-powershell"
    fi
fi

# --- macOS Category ---
if [ "$IS_MACOS" = true ]; then
    if command -v pbcopy >/dev/null; then
        test_copy "macOS" "pbcopy" "echo -n 'test-pbcopy' | pbcopy" "test-pbcopy"
    fi
fi

# --- Bypass Category ---
echo "INFO: To test the File Bypass, ensure this is running on your HOST:"
echo "      tail -F .clipboard_bypass > \$(tty)"
test_copy "Bypass" "File (.clipboard_bypass)" "printf '\e]52;c;dGVzdC1maWxlLWJ5cGFzcw==\a' > .clipboard_bypass" "test-file-bypass"

if [ -p ".clipboard_pipe" ]; then
    echo "INFO: To test the Named Pipe Bypass, ensure this is running on your HOST:"
    echo "      while true; do cat .clipboard_pipe; done > \$(tty)"
    test_copy "Bypass" "Named Pipe (.clipboard_pipe)" "printf '\e]52;c;dGVzdC1waXBlLWJ5cGFzcw==\a' > .clipboard_pipe" "test-pipe-bypass"
fi

BRIDGE_SCRIPT=".agents/skills/agent-bridge-clipboard/scripts/copy.sh"
if [ -f "$BRIDGE_SCRIPT" ]; then
    test_copy "Bridge" "copy.sh wrapper" "$BRIDGE_SCRIPT 'test-bridge-script'" "test-bridge-script"
fi

echo "-----------------------------------"
echo "Verification complete."
