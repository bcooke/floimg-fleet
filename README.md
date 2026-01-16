# Balustrade

> **Opinionated rails for Claude Code development**

Balustrade is a **meta-framework** providing structured guardrails for working with Claude Code.

**Meta-framework**: Manages the "meta" of Claude Code and agentic development - how you organize work, maintain context, and enforce standards.

**Primary job**: Give people and agents "rails" for Claude Code through an opinionated template.

**Language-agnostic. Minimal dependencies. Framework-focused.**

---

## What Is This?

A **reference implementation** showing how to use Claude Code's features together:
- **Git hooks** enforce conventions automatically (determinism)
- **Slash commands** guide consistent workflows (repeatability)
- **PROJECT_STATUS.md** provides token-efficient context (~500 vs 5000+ tokens)
- **Vault structure** organizes docs for both humans and agents (Obsidian patterns)

**This is both**:
1. **A template** - Fork it, customize it, make it yours
2. **An example** - Learn the patterns, adapt for your needs

**Not prescriptive**. Shows you HOW to build rails for YOUR conventions.

---

## What's Included

```
balustrade/
├── .claude/                    # THE FRAMEWORK (keep this)
│   ├── hooks/                  # Git hooks for enforcement
│   ├── commands/               # Slash commands for workflows
│   ├── agents/                 # Agent templates
│   ├── settings.json           # Claude Code config
│   └── aliases.sh              # Optional shell shortcuts
├── vault/                      # DOCUMENTATION PATTERNS (keep this)
│   ├── product/                # Product vision, user journeys
│   ├── architecture/           # System design, decisions
│   ├── features/               # Feature specifications
│   ├── _meta/                  # Writing guidelines
│   ├── how-to/                 # Process docs
│   └── pm/                     # Project management (tasks, context)
├── _reference/                 # REFERENCE MATERIALS (gitignored)
│   ├── repos/                  # Cloned repos for inspiration
│   ├── screenshots/            # UI mockups, design references
│   └── docs/                   # PDFs, PRDs, external specs
├── example-app/                # EXAMPLE APP (delete this)
│   ├── server.js               # Minimal Node HTTP server
│   ├── index.html              # Vanilla JS + Tailwind CDN
│   └── README.md               # "This is just an example"
├── .devcontainer/              # Dev container config
├── PROJECT_STATUS.md           # Status tracking template
└── README.md                   # This file
```

---

## Quick Start

### 1. Fork This Repository

```bash
# Or use as template on GitHub
```

### 2. Delete Example App

```bash
rm -rf example-app/
```

The example todo app is just for demonstration. Delete it.

### 3. Add Your App

**Node.js?**
```bash
npm init
# Add your Node code
```

**Python?**
```bash
python -m venv venv
# Add your Python code
```

**Mobile? Rust? Elixir? Anything?**

Balustrade is language-agnostic. The `.claude/` and `vault/` patterns work with any stack.

See `vault/how-to/Multi-Language Support.md` for examples.

### 4. Install Hooks

```bash
bash .claude/hooks/install-hooks.sh
```

This creates symlinks in `.git/hooks/`:
- `pre-commit` - Validates code quality, docs, PM discipline
- `commit-msg` - Validates conventional commit format
- `post-commit` - Auto-updates PROJECT_STATUS.md

### 5. Customize

- Update `PROJECT_STATUS.md` with your project name and priorities
- Edit `vault/product/` docs for your product vision
- Modify `.claude/hooks/pre-commit.sh` for your conventions
- Add your agents in `.claude/agents/`

### 6. Use Agents and Skills (Examples Included)

Balustrade includes example agents and skills to help you understand these Claude Code features:

**Example Agents** (`.claude/agents/`):
- `coordinator` - Multi-domain task coordination
- `full-stack-dev` - Feature implementation
- `code-reviewer` - Code quality review
- `bug-hunter` - Debugging specialist

**Example Skills** (`.claude/skills/`):
- `refactor` - Code refactoring patterns
- `test-setup` - Testing guidance
- `api-design` - REST API best practices
- `docs` - Documentation writing

**Use them**:
```
/call full-stack-dev Implement user profile editing
/call bug-hunter Debug login failure
/call code-reviewer Review auth module
```

**Customize them**: Replace with YOUR project's specialists and expertise!

### 7. Start Using Slash Commands

In Claude Code:

```
/status              # Quick status (reads PROJECT_STATUS.md only, ~500 tokens)
/p Add user auth     # Plan task (creates T-YYYY-NNN, updates status)
/s T-2025-001        # Start task (creates branch, updates status)
/ctx Key decision    # Update context doc
/call agent task     # Invoke specialized agent
/review              # Address PR feedback
/c                   # Close task (reviews, updates status, creates PR)
/wrap                # End-of-session summary
```

---

## The Real Value

### Not The Todo App

The example app (~100 lines) is just demonstration. Delete it.

### The Meta-Framework

**`.claude/` directory** shows how to:
- Enforce conventions with hooks
- Guide workflows with commands
- Coordinate with agents
- Integrate with Claude Code

**`vault/` structure** shows how to:
- Organize product documentation
- Track architecture decisions
- Manage PM workflows
- Write evergreen docs

**`PROJECT_STATUS.md`** shows:
- Token-efficient status tracking (~500 tokens vs 5000+)
- Single source of truth
- Auto-updated by hooks

---

## Core Concepts

### 1. Hooks Enforce Conventions

**Pre-commit** validates before commits:
- Temporal language in evergreen docs (example - customize for your rules)
- Task structure and status
- Task size warnings
- Your conventions here

**Commit-msg** enforces:
- Conventional commit format

**Post-commit** auto-updates:
- PROJECT_STATUS.md timestamp and recent files

**Pre-compaction** saves:
- Context before Claude's memory compression

### 2. Commands Guide Workflows

Slash commands maintain consistency:
- `/p` - Plan tasks with standard structure
- `/s` - Start tasks with branch creation
- `/c` - Close tasks with review checklist
- `/ctx` - Update context docs
- `/status` - Token-efficient status checks
- `/wrap` - Session summaries

### 3. Vault Organizes Knowledge

**Evergreen docs** (product/, architecture/, features/):
- Timeless, no temporal language
- Describe current state
- Heavily linked with `[[wiki links]]`

**PM docs** (pm/):
- Tasks with standard structure
- Context docs for working notes
- Temporal language OK here

### 4. Status Tracking Optimizes Tokens

`PROJECT_STATUS.md`:
- Single file with complete project state
- ~500 tokens vs 5000+ for scanning vault
- Auto-updated by hooks and commands
- Read this first, not the entire codebase

---

## Customization

### What To Keep

✅ `.claude/hooks/` structure (add your checks)
✅ `.claude/commands/` patterns (modify for your workflow)
✅ `vault/` organization (adapt for your domain)
✅ `PROJECT_STATUS.md` concept (your project state)

### What To Change

🔧 Specific hook validations (temporal language is just an example)
🔧 Agent definitions (add your specialists)
🔧 Vault sections (add your domains)
🔧 Dev container config (your stack)

### What To Delete

❌ `example-app/` (replace with your code)
❌ Todo app docs in `vault/` (replace with your product)
❌ Conventions that don't fit your project

See `CUSTOMIZATION.md` for step-by-step guide.

---

## Example Conventions

Balustrade includes these as **demonstrations**:

| Convention | What | Why | Customize |
|---|---|---|---|
| Temporal language | Block "will", "soon" in evergreen docs | Keeps docs current | Edit word list or remove |
| Task structure | Validate frontmatter fields | Consistent tracking | Add your fields |
| Task size | Warn if >7 checklist items | Right-sized work | Change threshold |
| Conventional commits | Enforce type(scope): format | Searchable history | Add your types |

**These are examples.** Add **your** conventions.

See `vault/how-to/Adding Your Conventions.md` for how to add:
- API naming standards
- Error handling patterns
- Test coverage requirements
- Database migration safety
- Documentation requirements
- Your team's rules

---

## Language Support

Works with **any** language or framework:

- **Node/Python/Ruby/Go** - Backend APIs
- **React/Vue/Angular** - Frontend apps
- **iOS/Android/Flutter** - Mobile apps
- **Rust/Elixir/C++** - Systems programming
- **Anything else** - It's just markdown + git hooks

The meta-framework is language-agnostic.

See `vault/how-to/Multi-Language Support.md`.

---

## Multi-Agent Workflows

Dev container enables multi-agent coordination:
- Multiple services in one environment
- Configurable ports
- Shared workspace
- Coordinated development

See `vault/how-to/Dev Container Setup.md`.

---

## Flexibility: Use What Works for You

Balustrade is **opinionated** about providing rails for Claude Code, but **flexible** about how you use it.

### Project Management

**What we provide**: Low-ceremony markdown-based PM that works great with Claude Code.

**Your options**:
1. **Use it as-is** - Markdown vault, Obsidian patterns, full workflow
2. **Use alongside other tools** - Keep Jira/Linear/Notion for team coordination, use Balustrade for Claude Code context
3. **Replace with your tools** - Use the hooks/commands, but connect to GitHub Issues, Linear API, etc.
4. **Pick and choose** - Maybe just use the docs structure, not the PM system
5. **Customize completely** - Use the patterns as inspiration, build your own

### Why This Works

**The core value is the meta-framework**:
- Hooks enforce YOUR standards (whatever they are)
- Commands guide YOUR workflows (however you define them)
- PROJECT_STATUS.md tracks YOUR work (from wherever it comes)
- Vault organizes YOUR knowledge (in whatever format you need)

**The specific implementation** (markdown PM, Obsidian patterns) is a practical **starting point** that:
- Works well with Claude Code out of the box
- Requires no external services or accounts
- Is easy to understand and modify
- Demonstrates the patterns in action

### Integration Examples

**If your team uses Jira**:
- Keep epic/story management in Jira
- Use Balustrade's `vault/` for technical documentation
- Create context docs that link to Jira tickets
- Hooks can validate Jira ticket references

**If your team uses Linear**:
- Create tasks in Linear for team visibility
- Use Balustrade for Claude Code's working context
- Sync status between Linear and PROJECT_STATUS.md
- Commands can create Linear issues via API

**If your team uses GitHub Issues**:
- Issues for bug tracking and feature requests
- Balustrade tasks for implementation tracking
- Context docs link to GitHub issues
- Hooks validate issue references in commits

**If you work solo**:
- Use Balustrade's full markdown PM system
- No external tools needed
- Fast, local, private
- Easy to customize

### What's Essential vs Optional

**Essential (the meta-framework)**:
- ✅ `.claude/hooks/` - Enforcement mechanism
- ✅ `.claude/commands/` - Workflow guidance
- ✅ `PROJECT_STATUS.md` - Context entry point
- ✅ Documentation structure - Human and agent readable

**Optional (this implementation)**:
- 📝 Markdown-based PM (could use APIs to other tools)
- 📝 Obsidian patterns (could use other editors)
- 📝 Specific vault structure (organize however you want)
- 📝 Task ID format (use whatever convention you prefer)

### The Point

**Balustrade shows you a practical approach** that works well with Claude Code.

**You adapt it to your needs**:
- Work solo? Use everything as-is
- Work on a team? Integrate with team tools
- Have strong opinions? Customize the patterns
- Just need docs? Use only the vault structure

**The meta-framework is the valuable part** - the specific implementation is just one way to use it.

---

## Obsidian Integration (Optional)

Balustrade works great with Obsidian for:
- Graph view of linked docs
- Backlinks and connections
- Fast full-text search
- Wiki-style navigation

**Why it works so well**: Obsidian community best practices (atomic notes, rich linking) are optimal for Claude Code's context management.

**But it's optional.** Use VS Code, terminal, or any editor.

See `vault/how-to/Obsidian Integration.md` for deep dive on why Obsidian + Claude Code work well together.

---

## What Makes This Different

### It's a Meta-Framework

**Not a code framework** - It's a framework for working with Claude Code:
- Manages the "meta" of development (how you work, not what you build)
- Provides rails for agents and humans
- Enforces YOUR conventions (not prescriptive ones)
- Optimizes for Claude Code's specific needs (context management, determinism)

**No npm install. No CLI. Just patterns.**

Fork the repo, customize it, make it yours.

### Opinionated About Process, Not Code

**Strong opinions about**:
- How to provide context to Claude Code efficiently
- How to enforce standards deterministically
- How to organize knowledge for humans and agents
- How to track work that Claude Code manages

**Zero opinions about**:
- What programming language you use
- What frameworks you choose
- What your product does
- How you architect your code

**Your code, your stack, your product.**

### Language-Agnostic

Works with **any** tech stack:
- Node, Python, Rust, Go, Ruby, Elixir
- React, Vue, Angular, Svelte
- iOS, Android, Flutter
- Any combination of the above

The `.claude/` directory and `vault/` structure sit alongside your code, regardless of language.

### Teaching By Example

**Includes minimal todo app** (~100 lines, zero dependencies):
- Shows patterns in action
- Not production code
- Delete it and replace with YOUR app

**The framework is the valuable part**, not the example.

---

## Documentation

**In this repo**:
- `HOW-IT-WORKS.md` - Visual walkthrough of the system
- `CUSTOMIZATION.md` - Make Balustrade yours
- `SUMMARY.md` - Complete file manifest and overview
- `vault/how-to/Meta-Framework.md` - Framework overview
- `vault/how-to/Hooks and Automation.md` - Hook details
- `vault/how-to/Git Workflow.md` - Commit conventions
- `vault/how-to/PM-Hierarchy.md` - Epics, Stories, Tasks, Bugs
- `vault/how-to/Adding Your Conventions.md` - Add your rules
- `vault/how-to/Using Reference Materials.md` - The `_reference/` pattern
- `vault/how-to/Multi-Language Support.md` - Any language
- `vault/how-to/Dev Container Setup.md` - Multi-agent setup
- `vault/how-to/Obsidian Integration.md` - Optional enhancement

**PM Templates** (in `vault/_templates/`):
- `Epic.md`, `Story.md`, `Task.md`, `Bug.md`, `Context.md` - Copy these to create new PM artifacts

**Example PM files** (in `vault/pm/`):
- `epics/E-2025-001-todo-app-mvp.md` - Example epic
- `stories/US-2025-001-setup-api.md` - Example user story
- `tasks/T-2025-001-setup-todo-api.md` - Example task
- `bugs/B-2025-001-fix-cors-error.md` - Example bug
- `_context/E-2025-001-context.md` - Example context doc

---

## Philosophy

### Convention Over Configuration

Like Ruby on Rails, Balustrade favors:
- Standard directory structure
- Predictable file naming
- Consistent workflows
- Automated maintenance

But for **project management**, not web apps.

### Determinism Over Flexibility

Hooks enforce standards automatically:
- No relying on memory
- No manual checklist
- Same validation every time
- Whether human or AI writes code

### Token Efficiency First

Every design decision optimizes for:
- Minimal context window usage (~10x reduction)
- Fast status checks (PROJECT_STATUS.md)
- Structured state tracking
- Preserved context across sessions

### Framework As Example

Don't copy prescriptively. Learn the patterns:
- See how hooks enforce conventions
- Understand command-guided workflows
- Study documentation organization
- Then adapt for your project

---

## Future: create-balustrade CLI

Eventually we may build `npx create-balustrade init` to install into existing projects.

For now: **fork and modify**.

---

## Contributing

Found a bug or want to improve the template?

1. File an issue describing the problem/enhancement
2. Submit PR with changes
3. Include example demonstrating value

---

## License

MIT - Use freely, modify as needed, no attribution required.

---

## Credits

Inspired by:
- Ruby on Rails (convention over configuration)
- Git hooks (right-time enforcement)
- Obsidian (linked knowledge)
- Claude Code (AI-assisted development)

Built to solve real problems in deterministic PM with AI.

---

## Get Started

1. **Fork** this repo
2. **Delete** example-app/
3. **Add** your code
4. **Customize** .claude/ and vault/
5. **Build** with deterministic guardrails

The balustrade guides your path. Now build something great.
