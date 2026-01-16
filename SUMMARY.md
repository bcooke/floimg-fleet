# Balustrade: Complete Summary

**Ultra-minimal, language-agnostic meta-framework template for Claude Code**

---

## What's Included

### Core Framework (58 files)
- 5 hooks (pre-commit, commit-msg, post-commit, pre-compaction, install)
- 10 slash commands (/p, /s, /c, /ctx, /status, /wrap, /call, /review, +legacy)
- 4 example agents (coordinator, full-stack-dev, code-reviewer, bug-hunter)
- 4 example skills (refactor, test-setup, api-design, docs)
- 9 vault how-to docs (includes PM-Hierarchy.md)
- 5 PM templates (Epic, Story, Task, Bug, Context)
- 3 example product docs (delete these)
- 9 example PM files (epic, stories, tasks, bug, context docs)
- 5 root files (README, CUSTOMIZATION, SUMMARY, HOW-IT-WORKS, PROJECT_STATUS)
- 1 dev container config
- 1 .gitignore

### Example App (~100 lines total)
- server.js: Node HTTP server, no dependencies
- index.html: Vanilla JS + Tailwind CDN
- **Purpose**: Reference only, delete and replace

---

## File Breakdown

### .claude/ (THE FRAMEWORK)
```
hooks/
  ├── pre-commit.sh         # Validates code, docs, PM discipline
  ├── commit-msg.sh         # Conventional commits
  ├── post-commit.sh        # Auto-updates PROJECT_STATUS.md
  ├── pre-compaction.sh     # Saves context before compression
  └── install-hooks.sh      # Installation script

commands/
  ├── p.md                  # Plan task
  ├── s.md                  # Start task
  ├── c.md                  # Close task
  ├── ctx.md                # Update context
  ├── status.md             # Quick status check
  ├── wrap.md               # Session summary
  ├── call.md               # Invoke agent
  ├── review.md             # Address PR feedback
  ├── start.md              # (legacy)
  └── commit.md             # (legacy)

agents/                     # Example agents (customize!)
  ├── coordinator.md        # Multi-domain coordination
  ├── full-stack-dev.md     # Feature implementation
  ├── code-reviewer.md      # Code quality review
  └── bug-hunter.md         # Debugging specialist

skills/                     # Example skills (customize!)
  ├── refactor.md           # Code refactoring patterns
  ├── test-setup.md         # Testing guidance
  ├── api-design.md         # REST API best practices
  └── docs.md               # Documentation writing

settings.json               # PreCompact hook config
aliases.sh                  # Optional shell shortcuts
```

### vault/ (DOCUMENTATION PATTERNS)
```
product/
  └── Product Vision.md     # Example - replace with yours

architecture/
  └── System Architecture.md # Example - replace with yours

features/
  └── Todo Management.md    # Example - replace with yours

_meta/
  └── Vault Writing Guidelines.md

how-to/
  ├── Meta-Framework.md
  ├── Hooks and Automation.md
  ├── Git Workflow.md
  ├── Multi-Language Support.md
  ├── Dev Container Setup.md
  ├── Obsidian Integration.md
  └── Adding Your Conventions.md

_templates/
  ├── Epic.md               # Template for creating epics
  ├── Story.md              # Template for creating stories
  ├── Task.md               # Template for creating tasks
  ├── Bug.md                # Template for creating bugs
  └── Context.md            # Template for context docs

pm/
  ├── epics/                # Epic files only
  │   └── E-2025-001-todo-app-mvp.md (example epic)
  ├── stories/              # User story files
  │   ├── US-2025-001-setup-api.md (example story)
  │   └── US-2025-002-build-frontend.md (example story)
  ├── tasks/                # Task files only
  │   ├── T-2025-001-setup-todo-api.md (example task)
  │   └── T-2025-002-create-html-interface.md (example task)
  ├── bugs/                 # Bug files only
  │   └── B-2025-001-fix-cors-error.md (example bug)
  └── _context/             # Context docs
      ├── E-2025-001-context.md (example epic context)
      └── T-2025-001-context.md (example task context)
```

### example-app/ (DELETE THIS)
```
server.js                   # 80 lines: Node HTTP API
index.html                  # 100 lines: Vanilla JS frontend
README.md                   # "This is just an example"
```

### Root Files
```
README.md                   # Main documentation
CUSTOMIZATION.md            # How to make it yours
PROJECT_STATUS.md           # Status tracking template
SUMMARY.md                  # This file
.gitignore                  # Generic ignores
.devcontainer/
  └── devcontainer.json     # Generic Ubuntu container
```

---

## Key Features

### 1. Language Agnostic
Works with any tech stack:
- Node, Python, Ruby, Go
- React, Vue, Angular
- iOS, Android, Flutter
- Rust, Elixir, C++, anything

### 2. Zero Dependencies
Example app has NO package.json, NO build step.
Just Node built-ins + vanilla JS + CDN Tailwind.

### 3. Framework Focused
Real value is `.claude/` and `vault/`, not the example app.
Delete example, keep framework.

### 4. Teaching By Example
Shows patterns via minimal todo app.
Then you replace with your project.

### 5. Fully Customizable
Every convention is an example.
Change hooks for YOUR rules.
Add YOUR agents.
Document YOUR product.

---

## What Gets Enforced (Examples)

These are demonstrations - customize for your needs:

**Pre-commit blocks**:
- Temporal language in evergreen docs (optional)
- Invalid task status (optional)
- Missing task fields (optional)
- Debugger statements (optional)
- Merge conflict markers (recommended)

**Pre-commit warns**:
- Task size >7 items (adjustable)
- Branch-task misalignment (optional)
- PROJECT_STATUS.md out of sync (optional)

**Commit-msg validates**:
- Conventional commit format (customizable)

**Post-commit updates**:
- PROJECT_STATUS.md timestamp (automatic)
- Recent files list (automatic)

---

## Quick Start (3 Steps)

1. **Fork** this repo
2. **Delete** example-app/
3. **Add** your code and customize

That's it.

---

## Customization Checklist

- [ ] Delete example-app/
- [ ] Add your code
- [ ] Update PROJECT_STATUS.md
- [ ] Replace vault/product/ docs
- [ ] Replace vault/architecture/ docs
- [ ] Replace vault/features/ docs
- [ ] Customize .claude/hooks/
- [ ] Add your agents
- [ ] Update dev container
- [ ] Install hooks: `bash .claude/hooks/install-hooks.sh`

See CUSTOMIZATION.md for details.

---

## Token Efficiency

**Problem**: Scanning vault for status costs 5000+ tokens

**Solution**: Read PROJECT_STATUS.md (500 tokens)

**Result**: ~10x reduction in common operations

**Usage**:
```
/status     # Reads PROJECT_STATUS.md only
            # Fast, cheap, always current
```

---

## Multi-Agent Ready

Dev container enables:
- Multiple services in one environment
- Configurable ports
- Shared workspace
- Agent coordination

See vault/how-to/Dev Container Setup.md

---

## Philosophy

### Not Prescriptive
Shows HOW to enforce conventions, not WHICH to enforce.

### Language Agnostic
Works with any stack. Framework is about PM, not code.

### Minimal Example
Todo app is ~100 lines. Easy to understand and delete.

### Framework First
Real value: `.claude/` patterns and `vault/` structure.

### Convention Over Configuration
Standard structure, predictable workflows, automated maintenance.

### Determinism Over Flexibility
Hooks enforce automatically. No relying on memory.

### Token Efficiency First
Every design optimizes for minimal context usage.

---

## What Makes This Different

**Not a framework**: No npm install, no CLI, just patterns
**Not opinionated about code**: Only about PM and docs
**Not language-specific**: Works with any stack
**Teaching by example**: Minimal todo app shows patterns

---

## Future: create-balustrade CLI

May eventually build:
```bash
npx create-balustrade init
```

For now: **fork and modify**.

---

## Documentation

All docs in vault/how-to/:
- Meta-Framework.md - Framework overview
- Hooks and Automation.md - Hook details
- Git Workflow.md - Commit conventions
- PM-Hierarchy.md - Epics, Stories, Tasks, Bugs explained
- Adding Your Conventions.md - Customize enforcement
- Multi-Language Support.md - Any language
- Dev Container Setup.md - Multi-agent setup
- Obsidian Integration.md - Optional enhancement

Plus:
- README.md - Main documentation
- HOW-IT-WORKS.md - Visual walkthrough of the system
- CUSTOMIZATION.md - Step-by-step customization
- SUMMARY.md - This file - Complete summary

---

## File Count

- **58 total files**
- 5 hooks
- 10 commands (/p, /s, /c, /ctx, /status, /wrap, /call, /review, +legacy)
- 4 example agents (coordinator, full-stack-dev, code-reviewer, bug-hunter)
- 4 example skills (refactor, test-setup, api-design, docs)
- 9 how-to docs (including PM-Hierarchy.md)
- 5 PM templates (Epic, Story, Task, Bug, Context)
- 3 example product docs (delete)
- 9 example PM files (epic, stories, tasks, bug, context)
- 5 root docs (README, HOW-IT-WORKS, CUSTOMIZATION, SUMMARY, PROJECT_STATUS)
- 1 dev container config
- 1 .gitignore
- 2 example app files

**Lines of code**: ~100 (example app)
**Lines of framework**: ~8000+ (docs, hooks, commands, agents, skills, templates, examples)

Framework is documentation and patterns, not code.

---

## Get Started

```bash
# Fork repo
# Delete example
rm -rf example-app/

# Add your code
# (any language)

# Install hooks
bash .claude/hooks/install-hooks.sh

# Start working
/p Your first task
/s T-2025-001
# Build!
```

---

## License

MIT - Use freely, modify, no attribution required.

---

## The Point

Balustrade is NOT:
- A todo app
- A Node.js framework
- A prescriptive system

Balustrade IS:
- A reference implementation
- Language-agnostic patterns
- Customizable for YOUR project

**Fork it. Delete the example. Make it yours.**

The balustrade guides your path. Now build.
