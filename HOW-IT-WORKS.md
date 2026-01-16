# How Balustrade Works

A visual walkthrough of how all the pieces fit together.

---

## The Big Picture

```
┌─────────────────────────────────────────────────────────────┐
│                      YOUR PROJECT                            │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │   Node.js  │  │   Python   │  │    Rust    │  (any code)│
│  │    Code    │  │    Code    │  │    Code    │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ Balustrade manages this ▼
┌─────────────────────────────────────────────────────────────┐
│                    BALUSTRADE LAYER                          │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    HOOKS     │  │   COMMANDS   │  │    VAULT     │     │
│  │  (Enforce)   │  │   (Guide)    │  │  (Document)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         ▲                 ▲                  ▲              │
│         └─────────────────┴──────────────────┘              │
│                    All work together                        │
└─────────────────────────────────────────────────────────────┘
```

**Key Insight**: Balustrade sits between your code and git, managing how you work with Claude Code.

---

## Problem It Solves

### Without Balustrade

```
User: "What's the status?"
Claude: *reads 10 files, scans git*
        [5000 tokens used]
        "You're working on auth..."

User: "Create a commit"
Claude: *creates commit with random format*
        (no validation, inconsistent messages)

User: "What conventions should I follow?"
Claude: *might remember, might forget*
        (no enforcement)
```

**Problems**:
- High token usage for simple questions
- Inconsistent workflows
- No enforcement of standards
- Context lost during compaction
- Manual tracking of everything

### With Balustrade

```
User: /status
Claude: *reads PROJECT_STATUS.md only*
        [500 tokens used]
        "Working on T-2025-007 (AI generation)"

User: git commit
Hook: *validates automatically*
      "❌ Invalid commit format"
      (blocks bad commits)

User: Adds temporal language to docs
Hook: *validates automatically*
      "❌ No 'will' in evergreen docs"
      (enforces your conventions)
```

**Benefits**:
- 10x token reduction for common operations
- Consistent, guided workflows
- Automatic enforcement
- Context preserved
- Hands-free tracking

---

## Core Components

### 1. Hooks (Enforcement)

**What**: Shell scripts that run automatically at git events

**When**: Before commits, after commits, before compaction

**Why**: Enforce standards without relying on memory

```
You attempt commit
        ▼
   pre-commit.sh runs
        ▼
   ┌─ Validates code quality
   ├─ Checks doc standards
   ├─ Validates task structure
   └─ Enforces YOUR conventions
        ▼
   ✅ Pass → commit proceeds
   ❌ Fail → commit blocked
```

**Example Flow**:
```bash
$ git add vault/product/Vision.md
$ git commit -m "add vision"

# Hook runs automatically:
❌ Found temporal language in vault/product/Vision.md
   Line 5: "We will implement this soon"
   Evergreen docs must describe current state

# Commit blocked! Fix the issue first.
```

**Hooks Included**:
- `pre-commit.sh` - Validates before commit
- `commit-msg.sh` - Validates commit message format
- `post-commit.sh` - Auto-updates PROJECT_STATUS.md
- `pre-compaction.sh` - Saves context before Claude's memory compression

### 2. Commands (Guided Workflows)

**What**: Slash commands that guide consistent task management

**When**: You invoke them in Claude Code (`/p`, `/s`, `/c`, etc.)

**Why**: Ensure every task follows same lifecycle

```
/p "Add user auth"
        ▼
   Creates task file
   Creates context doc
   Updates PROJECT_STATUS.md
   Commits everything
        ▼
   Task T-2025-001 ready!

/s T-2025-001
        ▼
   Creates branch feat/T-2025-001-add-user-auth
   Updates task status → in-progress
   Updates PROJECT_STATUS.md "Current Focus"
   Commits changes
        ▼
   Ready to work!

/c
        ▼
   Reviews completion
   Updates task status → completed
   Updates PROJECT_STATUS.md
   Offers to create PR
        ▼
   Task done!
```

**Commands Included**:
- `/p <description>` - Plan new task
- `/s <TASK-ID>` - Start task
- `/c` - Close task
- `/ctx <note>` - Update context
- `/status` - Quick status check (~500 tokens)
- `/wrap` - End-of-session summary
- `/groom` - Audit and sync PM state
- `/x <request>` - Escape hatch (bypass PM hooks)

### 3. Vault (Documentation)

**What**: Organized markdown files for product/architecture/PM

**When**: You document your product, not your code

**Why**: Knowledge graph of your project that works with Obsidian

```
vault/
├── product/           # Product vision (evergreen)
│   └── Vision.md
├── architecture/      # System design (evergreen)
│   └── Architecture.md
├── features/          # Feature specs (evergreen)
│   └── Auth.md
└── pm/                # Project management (temporal OK)
    ├── tasks/         # Task files (T-YYYY-NNN)
    ├── epics/         # Epic files (E-YYYY-NNN)
    └── _context/      # Working notes
```

**Evergreen docs** (product/, architecture/, features/):
- Timeless - describe current state
- No temporal language ("will", "soon", "recently")
- Hooks enforce this automatically

**PM docs** (pm/):
- Track progress and status
- Temporal language OK here
- Link to evergreen docs

### 4. PROJECT_STATUS.md (Token Efficiency)

**What**: Single file with complete project state

**When**: Read this FIRST before asking "what's the status?"

**Why**: ~500 tokens vs 5000+ for scanning vault

```
PROJECT_STATUS.md contains:
├── Current Focus (what task, what goal)
├── Recently Completed (last 3)
├── Next Up (top 3 priorities)
├── Open Questions / Blockers
├── Key Decisions (architectural)
└── Files Recently Modified (auto-updated)
```

**Token Comparison**:
```
Without PROJECT_STATUS.md:
  /status → reads 10+ vault files → 5000 tokens

With PROJECT_STATUS.md:
  /status → reads 1 file → 500 tokens

Result: 10x reduction
```

---

## How They Work Together

### Example: Starting New Work

```
1. You: /p Add email notifications

2. /p command:
   ├─ Creates vault/pm/tasks/T-2025-008-add-email-notifications.md
   ├─ Creates vault/pm/_context/T-2025-008-context.md
   ├─ Updates PROJECT_STATUS.md "Next Up"
   └─ Commits all files

3. You: /s T-2025-008

4. /s command:
   ├─ Creates branch feat/T-2025-008-add-email-notifications
   ├─ Updates task status → in-progress
   ├─ Updates PROJECT_STATUS.md "Current Focus"
   └─ Commits changes

5. You: *make code changes*

6. You: git commit -m "feat: add email service"

7. pre-commit hook runs:
   ├─ Checks for debugger statements ✅
   ├─ Checks for merge conflicts ✅
   ├─ Validates task structure ✅
   └─ Checks YOUR conventions ✅

8. commit-msg hook runs:
   └─ Validates "feat: add email service" format ✅

9. post-commit hook runs:
   └─ Updates PROJECT_STATUS.md timestamp ✅

10. You: /ctx Decided to use SendGrid over AWS SES

11. /ctx command:
    ├─ Appends to vault/pm/_context/T-2025-008-context.md
    ├─ Updates PROJECT_STATUS.md "Key Decisions"
    └─ Commits

12. You: /c

13. /c command:
    ├─ Reviews task checklist
    ├─ Updates task status → completed
    ├─ Moves to PROJECT_STATUS.md "Recently Completed"
    ├─ Offers to create PR
    └─ Commits

All automated. All consistent. Every time.
```

---

## The Flow (Visual)

### Task Lifecycle

```
┌──────────────────────────────────────────────────────┐
│                   TASK LIFECYCLE                      │
└──────────────────────────────────────────────────────┘

   /p                    /s                    /c
    │                     │                     │
    ▼                     ▼                     ▼
[BACKLOG] ───────▶ [IN-PROGRESS] ───────▶ [COMPLETED]
    │                     │                     │
    │                     │                     │
Creates:             Creates:             Creates:
- Task file          - Branch            - PR (optional)
- Context doc        - Updates status    - Final status
- Status entry       - Updates focus     - Move to history
```

### Token Usage Flow

```
WITHOUT BALUSTRADE:
User asks "status" → Claude scans vault → 10+ files → 5000 tokens
                                             ↓
                                        ❌ Expensive


WITH BALUSTRADE:
User asks "/status" → Claude reads PROJECT_STATUS.md → 1 file → 500 tokens
                                                          ↓
                                                     ✅ Efficient
```

### Hook Enforcement Flow

```
Code Change
    ▼
git add
    ▼
git commit ────────────┐
    ▼                  │
pre-commit hook runs   │  Validates:
    ├─ Code quality    │  - No debuggers
    ├─ Doc standards   │  - No temporal language
    ├─ Task structure  │  - Valid task status
    └─ Your rules ─────┘  - YOUR conventions
    ▼
✅ Pass → commit-msg hook
    ▼
✅ Pass → commit created
    ▼
post-commit hook runs
    └─ Updates PROJECT_STATUS.md
```

---

## What Makes It Different

### Not A Framework

No `npm install balustrade`. No CLI.

Just patterns you fork and modify.

### Language Agnostic

Works with:
- Node, Python, Ruby, Go
- React, Vue, Angular
- iOS, Android, Flutter
- Rust, Elixir, anything

The hooks/commands/vault work regardless of your code.

### Convention Examples, Not Rules

Balustrade checks temporal language as **demonstration**.

You should:
- Remove checks you don't want
- Add checks for YOUR conventions
- Customize for YOUR team

See `vault/how-to/Adding Your Conventions.md`.

### Teaching By Example

The todo app shows patterns in action:
- Product docs for todo features
- Architecture docs for simple API
- Task files for todo work

Delete it. Replace with YOUR product.

The patterns remain valuable.

---

## Core + Packs Architecture

Balustrade uses a **Core + Packs** model to stay simple while supporting different project types.

### Core (Universal)

The core includes patterns useful for **any project**:

```
.claude/
├── commands/          # Task lifecycle (/p, /s, /c, /ctx, /commit)
├── hooks/             # Git enforcement (pre-commit, commit-msg, etc.)
├── agents/            # Base coordinator agent
└── settings.json      # Hook configuration

vault/
├── _meta/             # Guidelines for using the vault
├── _templates/        # Task, epic, context templates
└── pm/                # Project management structure
```

**Core components**:
- Task lifecycle commands (`/p`, `/s`, `/c`, `/ctx`)
- Git hooks (pre-commit, commit-msg, post-commit)
- PROJECT_STATUS.md pattern
- Token-efficient workflows

### Packs (Copy What You Need)

Packs are pre-configured agents and templates for specific project types.

**Available Packs**:

| Pack | Use Case | What's Included |
|------|----------|-----------------|
| `saas/` | SaaS products | Product manager, UI/UX designer, user-tester agents + Product Vision, Personas, Pricing templates |
| `oss/` | Open source | (Coming soon) |

**How to Use Packs**:

1. **Find the pack** in `.claude/agents/_packs/` or `vault/_packs/`
2. **Copy what you need** to the main location:
   ```bash
   # Copy SaaS agents
   cp .claude/agents/_packs/saas/*.md .claude/agents/

   # Copy SaaS vault templates
   cp vault/_packs/saas/*.md vault/product/
   ```
3. **Customize** the copied files for your project
4. **Delete** what you don't need

**Example**: Building a SaaS product?

```bash
# Copy the SaaS pack agents
cp .claude/agents/_packs/saas/product-manager.md .claude/agents/
cp .claude/agents/_packs/saas/ui-ux-designer.md .claude/agents/
cp .claude/agents/_packs/saas/user-tester.md .claude/agents/

# Copy the SaaS vault templates
cp vault/_packs/saas/* vault/product/

# Now edit them for YOUR product!
```

The agents reference docs adaptively - they check if files exist before trying to use them.

---

## Key Design Principles

### 1. Determinism Over Flexibility

Hooks enforce automatically. Same result every time.

**Why**: No relying on Claude (or you) to remember conventions.

### 2. Token Efficiency First

Every design minimizes token usage:
- PROJECT_STATUS.md (single source of truth)
- Slash commands (structured updates)
- Hooks (no validation overhead)

**Result**: 10x reduction in common operations.

### 3. Convention Over Configuration

Standard structure, predictable workflows, automated maintenance.

**Like Rails**: Opinionated defaults you can change.

### 4. Framework As Example

Don't copy blindly. Learn the patterns:
- See how hooks enforce
- Understand command workflows
- Study vault organization
- Then adapt for your project

---

## FAQ: How Does This Work?

### "How do hooks run automatically?"

Git calls them at specific events:
- `pre-commit` → before commit is created
- `commit-msg` → after message is written
- `post-commit` → after commit succeeds

You install once: `bash .claude/hooks/install-hooks.sh`

Then they run automatically forever.

### "How does /status know what to read?"

The `/status` command tells Claude:
> "Read PROJECT_STATUS.md ONLY. Do not scan vault."

Claude follows instructions → reads 1 file → fast response.

### "How does PROJECT_STATUS.md stay current?"

Three ways:
1. **Slash commands** update it (/p, /s, /c)
2. **post-commit hook** updates timestamp/files
3. **You** can edit manually if needed

It's always in sync.

### "What if I don't want temporal language checks?"

Edit `.claude/hooks/pre-commit.sh`:

```bash
# Comment out the check:
# check_temporal_language "$FILE"
```

Or modify the word list. It's YOUR framework now.

### "Does this work with Python/Rust/Flutter?"

Yes! Hooks are bash scripts that run on git events.

They don't care what language your code is.

See `vault/how-to/Multi-Language Support.md`.

### "Do I need Obsidian?"

No. The `vault/` folder is just markdown.

Works with VS Code, vim, any editor.

Obsidian adds graph view and linking, but it's optional.

### "Can I add my own slash commands?"

Yes! Create `.claude/commands/your-command.md`:

```markdown
# Your Command

Steps:
1. Do thing
2. Update status
3. Commit
```

Then use `/your-command` in Claude Code.

---

## What You Should Do

### 1. Fork The Repo

This is a template. Make it yours.

### 2. Delete Example App

```bash
rm -rf example-app/
```

The todo app is just demonstration.

### 3. Add Your Code

Any language, any framework, any stack.

### 4. Customize Hooks

Edit `.claude/hooks/pre-commit.sh`:
- Remove checks you don't want
- Add checks for YOUR conventions
- Make it enforce YOUR standards

### 5. Document Your Product

Replace:
- `vault/product/` → YOUR product vision
- `vault/architecture/` → YOUR architecture
- `vault/features/` → YOUR features

### 6. Start Working

```bash
/p Your first task
/s T-2025-001
# Build!
```

---

## The Point

Balustrade is NOT:
- A todo app
- A framework you install
- A set of rules you must follow

Balustrade IS:
- A reference showing patterns
- A template you customize
- A foundation for YOUR conventions

**Fork it. Delete the example. Make it yours.**

The balustrade guides your path. Now build something great.
