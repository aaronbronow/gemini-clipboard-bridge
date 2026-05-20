UPSTREAM_DIR ?= ../agent-bridge-clipboard

.PHONY: import-upstream test

import-upstream:
	# Assume upstream has run 'make build'
	@if [ ! -d "$(UPSTREAM_DIR)/dist/gemini-clipboard-bridge" ]; then \
		echo "Error: $(UPSTREAM_DIR)/dist/gemini-clipboard-bridge not found."; \
		echo "Please run 'make build' in the upstream directory first."; \
		exit 1; \
	fi
	
	# Clear existing skills to ensure a clean state
	rm -rf skills/gemini-clipboard-bridge
	mkdir -p skills/gemini-clipboard-bridge
	
	# Copy the agent-specific skill folder
	cp -rv $(UPSTREAM_DIR)/dist/gemini-clipboard-bridge/* skills/gemini-clipboard-bridge/

test:
	./tests/integration.sh
