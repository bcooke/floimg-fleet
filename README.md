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

- **Elixir 1.18+** / **OTP 28+**
- **Phoenix 1.8** - Web framework
- **GenServer** - Bot state management
- **Supervisor trees** - Bot lifecycle

## Setup

```bash
# Install dependencies
mix deps.get

# Start development server
mix phx.server

# Or run interactively
iex -S mix phx.server
```

## Configuration

Create a `.env` file with:

```bash
FLOIMG_API_URL=https://api.floimg.com
FLOIMG_BOT_SECRET=xxx
LLM_PROVIDER=openai
LLM_API_KEY=xxx
```

## Architecture

```
FloimgFleet.Application
└── FloimgFleet.BotSupervisor
    ├── Bot #1 (GenServer) - personality, schedule, state
    ├── Bot #2 (GenServer)
    └── ...
```

Each bot is a supervised GenServer with:
- LLM-generated personality traits
- Activity scheduling
- Rate limiting
- Session state

## Development

```bash
# Run tests
mix test

# Format code
mix format

# Check warnings
mix compile --warnings-as-errors
```

## Related

- [FloImg](https://github.com/FlojoInc/floimg) - Core image workflow engine
- [FloImg Studio](https://studio.floimg.com) - Visual workflow builder
