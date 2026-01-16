# Example App

This is a **minimal reference implementation** showing what a Balustrade project might look like.

**Total:** ~100 lines of code, zero dependencies.

## What's Here

- `server.js` - Node HTTP server with 4 REST endpoints (no Express, no deps)
- `index.html` - Vanilla JS frontend with Tailwind via CDN

## Running It

```bash
# Start server
node server.js

# Open browser
open index.html
# Or visit: file:///path/to/index.html
```

## The Point

This is **NOT** the valuable part of Balustrade.

The valuable parts are:
- `.claude/` directory (hooks, commands, agents)
- `vault/` structure (product, architecture, PM)
- `PROJECT_STATUS.md` pattern

## What To Do

**Delete this directory** and add your own app:
- Python project? Delete this, add your `.py` files
- React app? Delete this, add your React code
- Mobile app? Delete this, document your iOS/Flutter/etc code

The `.claude/` and `vault/` patterns work with **any** tech stack.

## Why A Todo App?

Need some code to document as an example. Todo is:
- Universal (everyone understands it)
- Minimal (doesn't distract from the framework)
- Deletable (you won't keep it)
