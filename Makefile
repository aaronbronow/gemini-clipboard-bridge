UPSTREAM_DIR ?= ../agent-bridge-clipboard

.PHONY: import-upstream test

import-upstream:
	cd $(UPSTREAM_DIR) && $(MAKE) build
	# Vendor the full distribution for reference and testing
	mkdir -p .vendor/agent-bridge-clipboard
	cp -rv $(UPSTREAM_DIR)/dist/* .vendor/agent-bridge-clipboard/
	mkdir -p .vendor/agent-bridge-clipboard/tests
	cp -rv $(UPSTREAM_DIR)/tests/* .vendor/agent-bridge-clipboard/tests/
	# Bundle into top-level directories for extension distribution
	mkdir -p skills/gemini-clipboard-bridge commands/cb
	cp -rv .vendor/agent-bridge-clipboard/gemini/skills/agent-bridge-clipboard/* skills/gemini-clipboard-bridge/
	cp -rv .vendor/agent-bridge-clipboard/gemini/commands/abc/* commands/cb/
	# Fix script paths and re-brand commands/skills
	sed -i 's|\./\.agents/skills/agent-bridge-clipboard/scripts/copy.sh|~/.gemini/extensions/gemini-clipboard-bridge/skills/gemini-clipboard-bridge/scripts/copy.sh|g' commands/cb/*.toml
	sed -i 's/agent-bridge-clipboard/gemini-clipboard-bridge/g' commands/cb/*.toml skills/gemini-clipboard-bridge/SKILL.md
	sed -i 's/\/abc:/\/cb:/g' commands/cb/help.toml
	sed -i 's/(\/abc)/(\/cb)/g' commands/cb/help.toml
	sed -i 's/Agent Bridge Clipboard/Gemini Clipboard Bridge/g' commands/cb/help.toml
	# Sync version from gemini-extension.json
	VERSION=$$(grep '"version":' gemini-extension.json | cut -d'"' -f4); \
	sed -i "s/is [0-9.]*\\./is $$VERSION./g" commands/cb/version.toml

test:
	./tests/integration.sh
