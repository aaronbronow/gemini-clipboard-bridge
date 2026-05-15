#!/bin/bash
# Integration test for gemini-clipboard-bridge
# This script verifies downstream-specific integration, branding, and paths.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Gemini Clipboard Bridge Integration Tests ===${NC}\n"

ERRORS=0

check_file() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "[${GREEN}PASS${NC}] File exists: $file"
    else
        echo -e "[${RED}FAIL${NC}] File missing: $file"
        ERRORS=$((ERRORS + 1))
    fi
}

check_branding() {
    local file=$1
    local pattern="agent-bridge-clipboard"
    if grep -q "$pattern" "$file"; then
        echo -e "[${RED}FAIL${NC}] Branding leaked in $file: Found '$pattern'"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "[${GREEN}PASS${NC}] Branding clean in $file"
    fi
}

check_path() {
    local file=$1
    local pattern=$2
    if grep -q "$pattern" "$file"; then
        echo -e "[${GREEN}PASS${NC}] Path correct in $file: Found '$pattern'"
    else
        echo -e "[${RED}FAIL${NC}] Path incorrect in $file: Missing '$pattern'"
        ERRORS=$((ERRORS + 1))
    fi
}

# 1. Verify Directory Structure
echo -e "${BLUE}Checking Directory Structure...${NC}"
check_file "commands/cb/copy.toml"
check_file "commands/cb/help.toml"
check_file "commands/cb/version.toml"
check_file "skills/gemini-clipboard-bridge/SKILL.md"
check_file "skills/gemini-clipboard-bridge/scripts/copy.sh"

# 2. Verify Branding (No upstream names in downstream files)
echo -e "\n${BLUE}Verifying Branding...${NC}"
for f in commands/cb/*.toml skills/gemini-clipboard-bridge/SKILL.md; do
    check_branding "$f"
done

# 3. Verify Path Integrity in Commands
echo -e "\n${BLUE}Verifying Path Integrity...${NC}"
check_path "commands/cb/copy.toml" "~/.gemini/extensions/gemini-clipboard-bridge/skills/gemini-clipboard-bridge/scripts/copy.sh"

# 4. Verify Script Executability
echo -e "\n${BLUE}Verifying Script Permissions...${NC}"
if [ -x "skills/gemini-clipboard-bridge/scripts/copy.sh" ]; then
    echo -e "[${GREEN}PASS${NC}] copy.sh is executable"
else
    echo -e "[${RED}FAIL${NC}] copy.sh is NOT executable"
    ERRORS=$((ERRORS + 1))
fi

# 5. Verify CLI Prefix Re-branding
echo -e "\n${BLUE}Verifying Command Prefixes...${NC}"
if grep -q "/cb:" "commands/cb/help.toml" && ! grep -q "/abc:" "commands/cb/help.toml"; then
    echo -e "[${GREEN}PASS${NC}] Command prefixes correctly rebranded to /cb:"
else
    echo -e "[${RED}FAIL${NC}] Command prefix rebranding failed in help.toml"
    ERRORS=$((ERRORS + 1))
fi

echo -e "\n${BLUE}Summary:${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All integration tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$ERRORS tests failed.${NC}"
    exit 1
fi
