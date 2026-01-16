# Project Status

**Last Updated**: 2026-01-15
**Project**: FloImg Fleet

---

## Current Focus

**Active Task**: None - ready for next task
**Branch**: main
**Goal**: Admin panel complete, ready for API integration

---

## Recently Completed (Last 3)

- **T-2026-002** - Admin Panel LiveView with bot management dashboard
- **T-2026-001** - Set up Elixir/Phoenix project with CQRS architecture

---

## Next Up (Top 3 Priorities)

1. **FloImg API Client** - Req-based client for FloImg endpoints
2. **Bot Brain (LLM)** - LLM integration for personality and decisions
3. **Bot Actions** - Implement actual post/comment/like behaviors

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
- LiveView admin panel with real-time updates
- Start/pause/resume controls for individual and bulk operations
- Real-time activity feed via PubSub
- Dockerfile + docker-compose for deployment
- Health check endpoint at `/health`

---

## Notes

- This file is the **single source of truth** for project status
- Kept in sync with `vault/pm/` via hooks and slash commands
- Read this file first before asking "what's the status?"
