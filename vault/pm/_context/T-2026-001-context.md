# Context: T-2026-001 - Set Up FloImg Fleet Elixir/Phoenix Project

**Related**: [[T-2026-001-setup-elixir-phoenix-project]]
**Created**: 2026-01-15
**Last Updated**: 2026-01-15

---

## Overview

Setting up FloImg Fleet - an Elixir/Phoenix application for bot orchestration. The bots simulate user activity on FloImg Studio's gallery features to bootstrap platform engagement.

---

## Key References

### Idea Doc
Source: `floimg-hq/vault/ideas/bot-army-simulated-activity.md`

Key points:
- LLM-driven bots that simulate real user activity
- Focus on gallery/social features only (not SDK/OSS)
- Bots create images, upvote, comment, share
- Need human-like appearance
- Analytics separation required
- Cost efficiency is critical

### Technical Direction
- **Elixir/Phoenix stack** - Excellent for concurrent bot orchestration
- **GenServer primitives** - State management and supervision
- **API-first approach** - Call endpoints directly; Playwright fallback
- **Reference**: Charlie Holtz's "Shinstagram" from ElixirConf 2023

---

## Project Structure Plan

```
floimg-fleet/
├── lib/
│   ├── floimg_fleet/
│   │   ├── application.ex      # Main application supervisor
│   │   ├── bot_supervisor.ex   # Supervises bot processes
│   │   ├── bot.ex              # GenServer for individual bot
│   │   ├── personality.ex      # LLM-driven personality traits
│   │   └── api_client.ex       # FloImg API client
│   └── floimg_fleet_web/
│       ├── controllers/        # Dashboard controllers
│       ├── live/               # LiveView for real-time dashboard
│       └── router.ex
├── config/
├── priv/
└── test/
```

---

## Open Questions

- [ ] What LLM provider to use for bot personalities? (OpenAI, Anthropic, local?)
- [ ] How to handle FloImg API authentication for bots?
- [ ] What database to use for bot state persistence? (Postgres, SQLite, in-memory?)
- [ ] What's the target bot count for initial deployment?

---

## Progress Timeline

- **2026-01-15**: Task created, planning phase

---

## Notes

### Cleanup Required
- Remove Balustrade example-app (placeholder Todo app)
- Remove example PM tasks (T-2025-001, T-2025-002)
- Update README.md for FloImg Fleet

### Future Considerations
- Dashboard for monitoring bot activity
- Metrics on bot effectiveness
- Gradual phase-out strategy as real users grow

## Auto-saved State (2026-01-15 23:07)

Recent commits:
- feat: initialize Elixir/Phoenix project for FloImg Fleet
- chore: start work on T-2026-001
- chore: create task T-2026-001

**Note**: This entry was auto-generated before memory compaction.

