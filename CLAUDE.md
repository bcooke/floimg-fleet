# FloImg Fleet - Claude Code Quick Reference

FloImg Fleet is an agent orchestration system for simulating user activity on FloImg Studio's gallery features.

## What This Project Does

LLM-driven agents that:
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
├── agents.ex                  # Context gateway (CQRS)
├── agents/
│   ├── commands/              # Write operations
│   │   ├── create_agent.ex
│   │   ├── start_agent.ex
│   │   ├── pause_agent.ex
│   │   └── ...
│   ├── queries/               # Read operations
│   │   ├── list_agents.ex
│   │   ├── get_agent.ex
│   │   └── get_activity.ex
│   └── schemas/               # Ecto schemas
│       ├── agent.ex
│       └── agent_activity.ex
├── runtime/                   # OTP supervision
│   ├── agent_supervisor.ex    # DynamicSupervisor
│   └── agent_worker.ex        # GenServer per agent
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
# Write: Create an agent
FloimgFleet.Agents.create_agent(%{name: "Agent1", personality: "friendly"})

# Read: List all agents
FloimgFleet.Agents.list_agents()
```

The `FloimgFleet.Agents` context module is the public API gateway - it delegates to specific command/query modules.

### GenServer Per Agent

Each agent runs as a supervised GenServer process:

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

Agent lifecycle:
1. Configuration stored in Postgres (`agents` table)
2. Start agent → spawns GenServer process via DynamicSupervisor
3. Agent "thinks" periodically, decides actions based on probabilities
4. Actions logged to `agent_activities` table and broadcast via PubSub
5. Pause/resume/stop controls GenServer state

### Probabilistic Behavior

Each agent has configurable probabilities:
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
| `LLM_PROVIDER` | No | LLM provider: "ollama" or "openai" (default: "ollama") |
| `OLLAMA_URL` | No | Ollama server URL (default: http://localhost:11434) |
| `OLLAMA_MODEL` | No | Ollama model name (default: llama3.2) |
| `OPENAI_API_KEY` | No* | OpenAI API key (*required if LLM_PROVIDER=openai) |
| `OPENAI_MODEL` | No | OpenAI model (default: gpt-4o-mini) |

## Key Modules

| Module | Purpose |
|--------|---------|
| `FloimgFleet.Agents` | Context gateway - public API |
| `FloimgFleet.Agents.Schemas.Agent` | Ecto schema for agent configuration |
| `FloimgFleet.Agents.Schemas.AgentActivity` | Ecto schema for activity logs |
| `FloimgFleet.Runtime.AgentSupervisor` | DynamicSupervisor for agent processes |
| `FloimgFleet.Runtime.AgentWorker` | GenServer for individual agent state |
| `FloimgFleet.LLM.Client` | LLM client for generating agent content (Ollama/OpenAI) |

## Git Workflow

- **Branch naming**: `feat/T-YYYY-NNN-description`
- **Always use PRs** for changes
- **Linear history** via rebase

## Critical Rules

1. **Cost efficiency** - Minimize LLM tokens and API calls
2. **Human-like behavior** - Agents should not be detectable as automated
3. **No Claude co-authorship** - Never add `Co-Authored-By: Claude` in commits
4. **Private repo** - This code should never be public

## Reference Materials

Located in `_reference/`:
- `flojo/` - CQRS patterns from Flojo project
- `shinstagram/` - GenServer patterns (Charlie Holtz)
- `goflojo/` - Dockerfile and Coolify deployment patterns

## Vault Documentation

- `vault/product/Product Vision.md` - What and why
- `vault/architecture/System-Overview.md` - Architecture deep dive
- `vault/pm/tasks/` - Task tracking
