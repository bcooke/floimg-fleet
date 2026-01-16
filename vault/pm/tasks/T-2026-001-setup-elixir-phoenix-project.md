---
type: task
id: T-2026-001
story:
epic:
status: in-progress
priority: high
created: 2026-01-15
updated: 2026-01-15
---

# Task: Set Up FloImg Fleet Elixir/Phoenix Project

## Task Details
**Task ID**: T-2026-001-setup-elixir-phoenix-project
**Story**: N/A
**Epic**: N/A
**Status**: In Progress
**Priority**: High
**Branch**: feat/T-2026-001-setup-elixir-phoenix-project
**Created**: 2026-01-15
**Started**: 2026-01-15
**Completed**:

## Description
Initialize the FloImg Fleet project as an Elixir/Phoenix application. This is a bot orchestration system for simulating user activity on FloImg Studio's gallery features to bootstrap engagement and solve the cold-start problem.

Key requirements from the idea doc:
- LLM-driven bots with human-like personalities
- API-first approach (call endpoints directly)
- Playwright fallback for browser simulation
- GenServer primitives for bot state management and supervision
- Cost-efficient token/network usage

## Checklist
- [ ] Initialize Elixir/Phoenix project with `mix phx.new`
- [ ] Configure project structure for bot orchestration
- [ ] Set up basic supervision tree for bot management
- [ ] Add initial dependencies (HTTP client, JSON parsing)
- [ ] Create basic project documentation (README, CLAUDE.md)
- [ ] Clean up Balustrade example files (example-app, placeholder tasks)

## Technical Details
### Approach
- Phoenix framework for web interface/dashboard
- GenServer for individual bot state management
- Supervisor trees for bot lifecycle management
- API-first: bots call FloImg API endpoints directly
- Reference: Charlie Holtz's "Shinstagram" pattern from ElixirConf 2023

### Files to Create
- `lib/floimg_fleet/` - Core bot orchestration
- `lib/floimg_fleet_web/` - Phoenix web interface
- `config/` - Environment configuration
- `CLAUDE.md` - Project-specific Claude Code instructions

### Testing Required
- [ ] Mix compiles without errors
- [ ] Phoenix server starts successfully
- [ ] Basic supervision tree loads

### Documentation Updates
- Update README.md with FloImg Fleet purpose
- Create CLAUDE.md with project conventions

## Dependencies
### Blocked By
- None (greenfield project)

### Blocks
- Future bot implementation tasks

## Context
See [[T-2026-001-context]] for detailed implementation notes.

## Notes
- This is a private repo for internal use only
- Bot behavior should be stealthy but ethical
- Cost efficiency is critical (tokens, API calls)
