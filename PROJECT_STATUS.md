# Project Status

**Last Updated**: 2026-01-15
**Project**: FloImg Fleet

---

## Current Focus

**Active Task**: None - ready for next task
**Branch**: main
**Goal**: Bot orchestration foundation complete

---

## Recently Completed (Last 3)

- **T-2026-001** - Set up Elixir/Phoenix project with CQRS architecture

---

## Next Up (Top 3 Priorities)

1. **Admin Panel LiveView** - Bot management dashboard (start/pause/resume)
2. **FloImg API Client** - Req-based client for FloImg endpoints
3. **Bot Brain (LLM)** - LLM integration for personality and decisions

---

## Open Questions / Blockers

- LLM provider selection for bot personalities (OpenAI, Anthropic, Ollama?)
- FloImg API authentication strategy for bots

---

## Key Decisions

- **Stack**: Elixir 1.18 / Phoenix 1.8 / OTP 28
- **Database**: PostgreSQL with Ecto (binary_id)
- **Architecture**: CQRS pattern with GenServer per bot
- **Deployment**: Docker on Coolify (Hetzner)

---

## What's Been Built

- CQRS context (`FloimgFleet.Bots`) with commands/queries/schemas
- `Bot` and `BotActivity` schemas with migrations
- `BotSupervisor` (DynamicSupervisor) and `BotAgent` (GenServer)
- Dockerfile + docker-compose for deployment
- Health check endpoint at `/health`
- Full architecture documentation

---

## Notes

- This file is the **single source of truth** for project status
- Kept in sync with `vault/pm/` via hooks and slash commands
- Read this file first before asking "what's the status?"
