# Project Status

**Last Updated**: 2026-01-15
**Project**: FloImg Fleet

---

## Current Focus

**Active Task**: None - ready for next task
**Branch**: main
**Goal**: API client complete, ready for real API integration

---

## Recently Completed (Last 3)

- **T-2026-003** - FloImg API Client for bot interactions
- **T-2026-002** - Admin Panel LiveView with bot management dashboard
- **T-2026-001** - Set up Elixir/Phoenix project with CQRS architecture

---

## Next Up (Top 3 Priorities)

1. **Bot Brain (LLM)** - LLM integration for personality and content generation
2. **Real API Integration** - Connect to actual FloImg API endpoints
3. **Activity Logging** - Persist bot activities to database

---

## Open Questions / Blockers

- LLM provider selection for bot personalities (OpenAI, Anthropic, Ollama?)
- FloImg API endpoints need to be built to match expected interface

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
- **FloImg API client** with gallery and interaction endpoints
- BotAgent wired to API client for post/comment/like/browse
- Dockerfile + docker-compose for deployment
- Health check endpoint at `/health`

---

## Notes

- This file is the **single source of truth** for project status
- Kept in sync with `vault/pm/` via hooks and slash commands
- Read this file first before asking "what's the status?"
