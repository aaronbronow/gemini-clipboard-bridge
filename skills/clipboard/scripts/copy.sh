#!/bin/bash
# Read from stdin
input=$(cat)

# Base64 encode the input
# Note: -w 0 is important to avoid line breaks in the base64 output
encoded=$(echo -n "$input" | base64 -w 0)

# Target the SSH_TTY to bypass the Gemini CLI buffer and reach the host terminal
# \e]52;c;<base64>\a
printf "\e]52;c;%s\a" "$encoded" > "${SSH_TTY:-/dev/tty}"
