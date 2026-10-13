# AGENTS.md

Instructions for AI coding agents (Factory Droids and others) working in this repo.

All project rules live in **CLAUDE.md**. Read it in full before doing anything and follow it exactly:
architecture, state management, DI, error handling, code style, tests, commit message format,
and the "Never" list. If anything here ever conflicts with CLAUDE.md, CLAUDE.md wins.

Task instructions for the automated pipeline are in `.github/ai-prompts/` and are passed to you
by the GitHub workflows. Never modify `.github/` or `scripts/jira.sh`.
