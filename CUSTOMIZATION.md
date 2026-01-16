# Customizing Balustrade For Your Project

Step-by-step guide to replace the example with YOUR project.

---

## Quick Checklist

- [ ] Delete `example-app/`
- [ ] Add your code
- [ ] Update `PROJECT_STATUS.md`
- [ ] Replace `vault/product/` docs
- [ ] Replace `vault/architecture/` docs
- [ ] Replace `vault/features/` docs
- [ ] Customize `.claude/hooks/pre-commit.sh`
- [ ] Add your agents in `.claude/agents/`
- [ ] Update `.devcontainer/devcontainer.json`
- [ ] Install hooks: `bash .claude/hooks/install-hooks.sh`

---

## Step 1: Replace Example App

### Delete Example

```bash
rm -rf example-app/
```

### Add Your Code

**Node.js**:
```bash
npm init -y
npm install express
# Add your server code
```

**Python**:
```bash
python -m venv venv
source venv/bin/activate
pip install flask
# Add your Python code
```

**Any other language**: See `vault/how-to/Multi-Language Support.md`

---

## Step 2: Update PROJECT_STATUS.md

Edit `PROJECT_STATUS.md`:

```markdown
# Project Status

**Last Updated**: 2025-11-20  # Today
**Project**: MyAwesomeApp     # YOUR name

## Current Focus

**Active Task**: [Use /s to start first task]
**Branch**: main
**Goal**: Initial setup complete

## Next Up (Top 3 Priorities)

1. Set up database schema
2. Create authentication system
3. Build core API endpoints

## Key Decisions

- **Stack**: React + Node.js + PostgreSQL
- **Hosting**: Vercel + Render
- **Auth**: JWT tokens
```

---

## Step 3: Replace Product Docs

### vault/product/Product Vision.md

Replace todo app vision with yours:

```markdown
# Product Vision

## What We're Building

[Your product description]

## Problem We Solve

[User pain points]

## Our Solution

[How your product solves it]

## Target Users

[Who uses your product]

## Success Metrics

[How you measure success]
```

Delete temporal language ("will", "soon", "plans to").

---

## Step 4: Replace Architecture Docs

### vault/architecture/System Architecture.md

Document YOUR architecture:

```markdown
# System Architecture

## Components

- Frontend: React SPA
- API: Node.js + Express
- Database: PostgreSQL
- Cache: Redis
- Queue: Bull

## Data Flow

[How data moves through your system]

## Design Decisions

### Why PostgreSQL?
[Your reasoning]

### Why Redis?
[Your reasoning]
```

---

## Step 5: Replace Feature Docs

### vault/features/

Delete `Todo Management.md`.

Add your features:

```bash
cd vault/features/
rm Todo\ Management.md

# Add your features
touch User\ Authentication.md
touch Dashboard.md
touch Reporting.md
```

Each feature file:
```markdown
# Feature Name

## Overview

[What this feature does]

## User Capabilities

- [Capability 1]
- [Capability 2]

## Implementation Notes

[Technical details]

## Related

- [[Product Vision]]
- [[System Architecture]]
```

---

## Step 6: Customize Hooks

### Remove Example Conventions You Don't Want

Edit `.claude/hooks/pre-commit.sh`:

**Don't care about temporal language?** Comment out:
```bash
# check_temporal_language "$FILE"
```

**Different task structure?** Modify:
```bash
validate_task_frontmatter() {
    # Add your required fields
    if ! grep -q '^your_field:' "$file"; then
        echo "❌ Missing your_field"
        exit 1
    fi
}
```

### Add Your Conventions

See `vault/how-to/Adding Your Conventions.md` for examples:
- API naming standards
- Error handling patterns
- Test requirements
- Database migration safety

Add checks to `pre-commit.sh`:
```bash
check_my_convention() {
    # Your validation logic
}

# Then add to checks section
check_my_convention "$FILE"
```

---

## Step 7: Add Your Agents

### Example: Backend Developer Agent

Create `.claude/agents/backend-dev.md`:

```markdown
# Backend Developer

You are a backend development specialist.

## Responsibilities

- API endpoint design and implementation
- Database schema design
- Performance optimization
- Security best practices

## Guidelines

- Follow RESTful conventions
- Write tests for all endpoints
- Document API with OpenAPI
- Use prepared statements (SQL injection prevention)

## Tech Stack

- Node.js + Express
- PostgreSQL
- Redis for caching
- Bull for job queues
```

### Example: Frontend Developer Agent

Create `.claude/agents/frontend-dev.md`:

```markdown
# Frontend Developer

You are a frontend development specialist.

## Responsibilities

- React component development
- State management
- UI/UX implementation
- Performance optimization

## Guidelines

- Follow React best practices
- Use TypeScript for type safety
- Write unit tests with Vitest
- Ensure accessibility (WCAG 2.1 AA)

## Tech Stack

- React 18
- TypeScript
- Tailwind CSS
- Zustand for state
```

---

## Step 8: Update Dev Container

Edit `.devcontainer/devcontainer.json`:

### For Node + Postgres

```json
{
  "name": "my-app",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "forwardPorts": [3000, 5432],
  "postCreateCommand": "npm install",
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ]
    }
  }
}
```

Create `docker-compose.yml`:
```yaml
services:
  app:
    image: mcr.microsoft.com/devcontainers/javascript-node:20
    volumes:
      - .:/workspace
    command: sleep infinity

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
    ports:
      - "5432:5432"
```

### For Python

```json
{
  "name": "python-app",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "forwardPorts": [8000],
  "postCreateCommand": "pip install -r requirements.txt"
}
```

---

## Step 9: Create First Tasks

Use slash commands:

```
/p Set up database schema
/p Create user authentication
/p Build core API endpoints
```

This creates:
- `vault/pm/tasks/T-2025-001-set-up-database-schema.md`
- `vault/pm/tasks/T-2025-002-create-user-authentication.md`
- `vault/pm/tasks/T-2025-003-build-core-api-endpoints.md`

Updates `PROJECT_STATUS.md` "Next Up" section.

---

## Step 10: Start Working

```
/s T-2025-001
```

This:
- Creates branch `feat/T-2025-001-set-up-database-schema`
- Updates task status to `in-progress`
- Updates `PROJECT_STATUS.md` "Current Focus"
- Creates context doc

Now build your app!

---

## Common Customizations

### Change Task ID Format

Edit `.claude/commands/p.md` to change from `T-YYYY-NNN` to your format.

### Add More Slash Commands

Create new `.md` files in `.claude/commands/`:

Example: `.claude/commands/deploy.md`
```markdown
# Deploy

Deploy the application to production.

## Steps

1. Run tests
2. Build production bundle
3. Deploy to hosting
4. Verify deployment
5. Update PROJECT_STATUS.md
```

### Modify Hook Strictness

**Block vs Warn**:

Block (fails commit):
```bash
exit 1
```

Warn (shows message but allows):
```bash
# Don't exit, just echo warning
```

### Add Pre-Push Validation

Create `.claude/hooks/pre-push.sh`:
```bash
#!/bin/bash
# Runs before git push

# Example: Run tests before push
npm test || exit 1
```

Then symlink:
```bash
ln -s ../../.claude/hooks/pre-push.sh .git/hooks/pre-push
```

---

## Verification

After customization, verify:

```bash
# 1. Hooks installed?
ls -l .git/hooks/ | grep '.claude'

# 2. Hooks executable?
ls -l .claude/hooks/*.sh

# 3. Test pre-commit
git add .
git commit -m "test: verify hooks"
# Should validate

# 4. Test slash commands
# In Claude Code:
/status
# Should read PROJECT_STATUS.md

# 5. Test task lifecycle
/p Test task creation
/s T-2025-XXX
/c
```

---

## You're Done!

Balustrade is now customized for your project:
- Your code replacing example
- Your product vision
- Your architecture decisions
- Your conventions enforced
- Your agents defined
- Your workflow automated

Build something great with deterministic guardrails.
