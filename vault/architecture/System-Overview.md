# FloImg Fleet - System Overview

FloImg Fleet is a bot orchestration system for simulating user activity on FloImg Studio's gallery features.

## Purpose

Solve the cold-start problem for FloImg Studio's social features by creating LLM-driven bots that:
- Create and share images in the gallery
- Upvote and interact with content
- Leave comments
- Make the platform feel alive to new users

## Architecture Patterns

### CQRS (Command Query Responsibility Segregation)

Following the Flojo pattern, we separate read and write operations:

```
lib/floimg_fleet/bots/
├── commands/          # Write operations
│   ├── create_bot.ex
│   ├── start_bot.ex
│   ├── pause_bot.ex
│   └── ...
├── queries/           # Read operations
│   ├── list_bots.ex
│   ├── get_bot.ex
│   └── get_activity.ex
└── schemas/           # Ecto schemas
    ├── bot.ex
    └── bot_activity.ex
```

**Context Gateway**: `FloimgFleet.Bots` module provides the public API, delegating to commands and queries.

### Bot Runtime (GenServer per Bot)

Following the Shinstagram pattern:

```
lib/floimg_fleet/runtime/
├── bot_supervisor.ex   # DynamicSupervisor
└── bot_agent.ex        # GenServer per bot
```

**Lifecycle**:
1. Bot configuration stored in Postgres
2. When started, a GenServer process is created
3. Bot "thinks" periodically, decides actions based on probabilities
4. Actions logged to database and broadcast via PubSub
5. When stopped, GenServer terminates gracefully

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

## Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Admin Panel   │────▶│   Bots Context   │────▶│    Postgres     │
│   (LiveView)    │     │   (Commands/     │     │  (Bot configs)  │
└─────────────────┘     │    Queries)      │     └─────────────────┘
        │               └──────────────────┘              │
        │                        │                        │
        ▼                        ▼                        │
┌─────────────────┐     ┌──────────────────┐              │
│   PubSub        │◀────│  Bot Supervisor  │              │
│   (Activity)    │     │  + Bot Agents    │◀─────────────┘
└─────────────────┘     └──────────────────┘
        │                        │
        ▼                        ▼
┌─────────────────┐     ┌──────────────────┐
│  Activity Feed  │     │   FloImg API     │
│  (LiveView)     │     │   (External)     │
└─────────────────┘     └──────────────────┘
```

## Key Decisions

### Bot State Split
- **Persistent state** (Postgres): Bot configuration, personality, behavior settings
- **Runtime state** (GenServer): Current action, last thought, paused flag

### Activity Logging
- All bot actions logged to `bot_activities` table for analytics
- Real-time updates via Phoenix PubSub for live dashboard

### Probabilistic Behavior
- Each bot has configurable probabilities for post/comment/like/browse
- Action intervals randomized within configured min/max bounds
- Creates human-like unpredictable behavior

## Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Phoenix 1.8 |
| Language | Elixir 1.18 / OTP 28 |
| Database | PostgreSQL |
| ORM | Ecto |
| Process Mgmt | GenServer + DynamicSupervisor |
| Real-time | Phoenix PubSub + LiveView |
| Background Jobs | Oban (future) |
| HTTP Client | Req |
| Deployment | Docker on Coolify |

## Related Documents

- [[Bot-Schema]] - Database schema design
- [[Admin-Panel]] - LiveView admin interface
- [[FloImg-API-Integration]] - API client for FloImg
