# Project Tooling

## Codex CLI
- Wrapper: `./bin/codex` pins the model to `gpt-5` for this repo.
- Override per-run: pass `-m`/`--model` (wrapper respects overrides).
- Make target: `make codex ARGS="..."` runs the wrapper with arguments.

Examples
- `./bin/codex --version`
- `make codex ARGS="Refactor utils for clarity"`
- `./bin/codex -i screenshot.png "Summarize this UI"`

Prerequisite
- Install Codex CLI (`codex --version` should work on your PATH).
