# FloImg Fleet

Bot orchestration system for simulating user activity on FloImg Studio.

## Overview

FloImg Fleet creates LLM-driven bots that interact with FloImg Studio's gallery features to bootstrap engagement and solve the cold-start problem for new social platforms.

**What bots do:**
- Create and share images in the gallery
- Upvote and interact with content
- Leave comments
- Make the platform feel alive

**What bots don't do:**
- Create plugins or templates
- Make OSS contributions
- Anything outside gallery/social features

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

## Setup

### Prerequisites

- Elixir 1.18+
- PostgreSQL 16+
- Node.js (for assets)

### Development

```bash
# Install dependencies
mix setup

# Create and migrate database
mix ecto.setup

# Start development server
mix phx.server

# Or run interactively
iex -S mix phx.server
```

### Docker

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

## Architecture

```
lib/floimg_fleet/
├── bots.ex                    # Context gateway (CQRS)
├── bots/
│   ├── commands/              # Write operations
│   │   ├── create_bot.ex
│   │   ├── start_bot.ex
│   │   └── pause_bot.ex
│   ├── queries/               # Read operations
│   │   ├── list_bots.ex
│   │   └── get_activity.ex
│   └── schemas/               # Ecto schemas
│       ├── bot.ex
│       └── bot_activity.ex
├── runtime/                   # OTP supervision
│   ├── bot_supervisor.ex      # DynamicSupervisor
│   └── bot_agent.ex           # GenServer per bot
└── repo.ex                    # Ecto repository
```

### Supervision Tree

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

### Bot Lifecycle

1. Create bot configuration (stored in Postgres)
2. Start bot → spawns GenServer process
3. Bot "thinks" periodically, decides actions
4. Actions logged to DB and broadcast via PubSub
5. Pause/resume/stop via admin panel

## Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes (prod) | PostgreSQL connection string |
| `SECRET_KEY_BASE` | Yes (prod) | Phoenix secret (generate with `mix phx.gen.secret`) |
| `PHX_HOST` | Yes (prod) | Production hostname |
| `PORT` | No | HTTP port (default: 4000) |
| `POOL_SIZE` | No | DB connection pool (default: 10) |
| `FLOIMG_API_URL` | No | FloImg API endpoint |
| `FLOIMG_BOT_SECRET` | No | Bot authentication secret |

## Development

```bash
# Run tests
mix test

# Format code
mix format

# Check warnings
mix compile --warnings-as-errors

# Run all checks
mix precommit
```

## Deployment

Deployed via Coolify on Hetzner infrastructure.

1. Push to main branch
2. Coolify auto-deploys via webhook
3. Migrations run automatically on startup

### Health Check

```bash
curl http://localhost:4000/health
# {"status":"ok"}
```

## Related

- [FloImg](https://github.com/FlojoInc/floimg) - Core image workflow engine
- [FloImg Studio](https://studio.floimg.com) - Visual workflow builder

## Documentation

See `vault/` for detailed documentation:
- `vault/architecture/System-Overview.md` - Architecture deep dive
- `vault/pm/` - Project management artifacts
