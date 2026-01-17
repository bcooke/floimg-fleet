# FloImg Fleet - Claude Code Quick Reference

FloImg Fleet is a bot orchestration system for simulating user activity on FloImg Studio's gallery features.

## What This Project Does

LLM-driven bots that:
- Create and share images in the gallery
- Upvote and interact with content
- Leave comments
- Make the platform feel alive to new users

This solves the cold-start problem for FloImg Studio's social features.

## Stack

| Component | Technology |
|-----------|------------|
| Framework | Phoenix 1.8 |
| Language | Elixir 1.18 / OTP 28 |
| Database | PostgreSQL |
| ORM | Ecto |
| Process Mgmt | GenServer + DynamicSupervisor |
| Real-time | Phoenix PubSub + LiveView |
| HTTP Client | Req |
| Deployment | Docker on Coolify |

## Project Structure

```
lib/floimg_fleet/
├── bots.ex                    # Context gateway (CQRS)
├── bots/
│   ├── commands/              # Write operations
│   │   ├── create_bot.ex
│   │   ├── start_bot.ex
│   │   ├── pause_bot.ex
│   │   └── ...
│   ├── queries/               # Read operations
│   │   ├── list_bots.ex
│   │   ├── get_bot.ex
│   │   └── get_activity.ex
│   └── schemas/               # Ecto schemas
│       ├── bot.ex
│       └── bot_activity.ex
├── runtime/                   # OTP supervision
│   ├── bot_supervisor.ex      # DynamicSupervisor
│   └── bot_agent.ex           # GenServer per bot
└── repo.ex                    # Ecto repository

lib/floimg_fleet_web/          # Phoenix web interface
├── controllers/
├── components/
└── router.ex

config/                        # Environment configuration
test/                          # Tests
vault/                         # PM artifacts and documentation
```

## Architecture Patterns

### CQRS (Command Query Responsibility Segregation)

Write operations go through Commands, read operations through Queries:

```elixir
# Write: Create a bot
FloimgFleet.Bots.create_bot(%{name: "Bot1", personality: "friendly"})

# Read: List all bots
FloimgFleet.Bots.list_bots()
```

The `FloimgFleet.Bots` context module is the public API gateway - it delegates to specific command/query modules.

### GenServer Per Bot

Each bot runs as a supervised GenServer process:

```
FloimgFleet.Application
├── FloimgFleet.Repo
├── Phoenix.PubSub
├── FloimgFleet.Runtime.BotSupervisor
│   ├── BotAgent (bot 1)
│   ├── BotAgent (bot 2)
│   └── ...
└── FloimgFleetWeb.Endpoint
```

Bot lifecycle:
1. Configuration stored in Postgres (`bots` table)
2. Start bot → spawns GenServer process via DynamicSupervisor
3. Bot "thinks" periodically, decides actions based on probabilities
4. Actions logged to `bot_activities` table and broadcast via PubSub
5. Pause/resume/stop controls GenServer state

### Probabilistic Behavior

Each bot has configurable probabilities:
- `post_probability` - Chance to create a new post
- `comment_probability` - Chance to leave a comment
- `like_probability` - Chance to like content
- Action intervals randomized between min/max bounds

## Commands

```bash
# Install dependencies
mix setup

# Create and migrate database
mix ecto.setup

# Start development server
mix phx.server

# Or run interactively
iex -S mix phx.server

# Run tests
mix test

# Format code
mix format

# Check for issues
mix compile --warnings-as-errors

# Run all checks
mix precommit
```

## Docker

```bash
# Start with docker-compose (includes Postgres)
docker compose up

# Or build and run standalone
docker build -t floimg-fleet .
docker run -p 4000:4000 \
  -e DATABASE_URL=ecto://user:pass@host/floimg_fleet \
  -e SECRET_KEY_BASE=$(mix phx.gen.secret) \
  -e PHX_HOST=localhost \
  floimg-fleet
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes (prod) | PostgreSQL connection string |
| `SECRET_KEY_BASE` | Yes (prod) | Phoenix secret (generate with `mix phx.gen.secret`) |
| `PHX_HOST` | Yes (prod) | Production hostname |
| `PORT` | No | HTTP port (default: 4000) |
| `POOL_SIZE` | No | DB connection pool (default: 10) |
| `FLOIMG_API_URL` | No | FloImg API endpoint (default: https://api.floimg.com) |
| `FLOIMG_SERVICE_TOKEN` | Yes (prod) | Service token for FloImg API authentication (format: fst_...) |

## Key Modules

| Module | Purpose |
|--------|---------|
| `FloimgFleet.Bots` | Context gateway - public API |
| `FloimgFleet.Bots.Schemas.Bot` | Ecto schema for bot configuration |
| `FloimgFleet.Bots.Schemas.BotActivity` | Ecto schema for activity logs |
| `FloimgFleet.Runtime.BotSupervisor` | DynamicSupervisor for bot processes |
| `FloimgFleet.Runtime.BotAgent` | GenServer for individual bot state |

## Git Workflow

- **Branch naming**: `feat/T-YYYY-NNN-description`
- **Always use PRs** for changes
- **Linear history** via rebase

## Critical Rules

1. **Cost efficiency** - Minimize LLM tokens and API calls
2. **Human-like behavior** - Bots should not be detectable as bots
3. **No Claude co-authorship** - Never add `Co-Authored-By: Claude` in commits
4. **Private repo** - This code should never be public

## Reference Materials

Located in `_reference/`:
- `flojo/` - CQRS patterns from Flojo project
- `shinstagram/` - GenServer bot patterns (Charlie Holtz)
- `goflojo/` - Dockerfile and Coolify deployment patterns

## Vault Documentation

- `vault/product/Product Vision.md` - What and why
- `vault/architecture/System-Overview.md` - Architecture deep dive
- `vault/pm/tasks/` - Task tracking
