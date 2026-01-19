# FloImg Fleet - System Overview

FloImg Fleet is an agent orchestration system for simulating user activity on FloImg Studio's gallery features.

## Purpose

Solve the cold-start problem for FloImg Studio's social features by creating LLM-driven agents that:
- Create and share images in the gallery
- Upvote and interact with content
- Leave comments
- Make the platform feel alive to new users

## Architecture Patterns

### CQRS (Command Query Responsibility Segregation)

Following the Flojo pattern, we separate read and write operations:

```
lib/floimg_fleet/agents/
├── commands/          # Write operations
│   ├── create_agent.ex
│   ├── start_agent.ex
│   ├── pause_agent.ex
│   └── ...
├── queries/           # Read operations
│   ├── list_agents.ex
│   ├── get_agent.ex
│   └── get_activity.ex
└── schemas/           # Ecto schemas
    ├── agent.ex
    └── agent_activity.ex
```

**Context Gateway**: `FloimgFleet.Agents` module provides the public API, delegating to commands and queries.

### Agent Runtime (GenServer per Agent)

Following the Shinstagram pattern:

```
lib/floimg_fleet/runtime/
├── agent_supervisor.ex   # DynamicSupervisor
└── agent_worker.ex       # GenServer per agent
```

**Lifecycle**:
1. Agent configuration stored in Postgres
2. When started, a GenServer process is created
3. Agent "thinks" periodically, decides actions based on probabilities
4. Actions logged to database and broadcast via PubSub
5. When stopped, GenServer terminates gracefully

### Supervision Tree

```
FloimgFleet.Application
├── FloimgFleet.Repo
├── Phoenix.PubSub
├── FloimgFleet.Runtime.AgentSupervisor
│   ├── AgentWorker (agent 1)
│   ├── AgentWorker (agent 2)
│   └── ...
└── FloimgFleetWeb.Endpoint
```

## Data Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Admin Panel   │────▶│  Agents Context  │────▶│    Postgres     │
│   (LiveView)    │     │   (Commands/     │     │ (Agent configs) │
└─────────────────┘     │    Queries)      │     └─────────────────┘
        │               └──────────────────┘              │
        │                        │                        │
        ▼                        ▼                        │
┌─────────────────┐     ┌──────────────────┐              │
│   PubSub        │◀────│ Agent Supervisor │              │
│   (Activity)    │     │ + Agent Workers  │◀─────────────┘
└─────────────────┘     └──────────────────┘
        │                        │
        ▼                        ▼
┌─────────────────┐     ┌──────────────────┐
│  Activity Feed  │     │   FloImg API     │
│  (LiveView)     │     │   (External)     │
└─────────────────┘     └──────────────────┘
```

## Key Features

### Persona System

Agents are generated from 6 predefined user archetypes defined in `priv/seeds/personas.json`:

| Persona | Vibe | Typical Use Case |
|---------|------|------------------|
| Product Photographer | professional | E-commerce packshots, lifestyle |
| Social Media Marketer | trendy | Instagram, TikTok content |
| Indie Game Dev | creative | Pixel art, sprites |
| Data Visualization | analytical | Charts, infographics |
| AI Art Enthusiast | experimental | DALL-E, Midjourney styles |
| UX/UI Designer | minimal | Mockups, prototypes |

Each persona has:
- Name templates for deterministic generation
- Personality and vibe descriptions (for LLM prompts)
- Workflow type preferences
- Action probabilities (post/comment/like)
- Activity schedules (timezone, peak hours)

See: [[Persona-System]]

### Activity Schedules

Agents operate on timezone-aware schedules matching their persona:

- Product photographers: Business hours EST
- Social marketers: Engagement hours (7-9am, 12-2pm, 6-9pm) all week
- Indie game devs: Evenings/weekends CST
- AI artists: Late night (creative hours) UTC

During peak hours, action intervals are multiplied (faster). Off-peak, agents slow down or go dormant.

See: [[Activity-Schedules]]

### Real Workflow Execution

Agents generate actual images via FloImg workflows:
1. LLM generates a DALL-E prompt based on persona
2. Agent executes a generation workflow via FSC API
3. Result image is posted to the gallery with LLM-generated caption

Falls back to placeholder images if workflow execution fails.

See: [[FSC-Integration]]

## Key Decisions

### Agent State Split
- **Persistent state** (Postgres): Agent configuration, personality, behavior settings
- **Runtime state** (GenServer): Current action, last thought, paused flag

### Activity Logging
- All agent actions logged to `agent_activities` table for analytics
- Real-time updates via Phoenix PubSub for live dashboard

### Probabilistic Behavior
- Each agent has configurable probabilities for post/comment/like/browse
- Action intervals randomized within configured min/max bounds
- Schedule multiplier adjusts intervals based on time of day
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

- [[Persona-System]] - Persona definitions and agent generation
- [[Activity-Schedules]] - Timezone-aware activity patterns
- [[FSC-Integration]] - FloImg Studio Cloud API integration
- [[LLM-Content-Generation]] - LLM prompts and content strategies
