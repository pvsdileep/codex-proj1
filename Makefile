.PHONY: codex

# Run Codex CLI pinned to gpt-5 via the repo wrapper.
# Usage examples:
#   make codex ARGS="--version"
#   make codex ARGS="Fix tests in api/ and add logging"
codex:
	./bin/codex $(ARGS)

