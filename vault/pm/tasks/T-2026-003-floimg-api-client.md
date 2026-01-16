---
type: task
id: T-2026-003
story:
epic:
status: in-progress
priority: high
created: 2026-01-15
updated: 2026-01-15
---

# Task: FloImg API Client

## Task Details
**Task ID**: T-2026-003-floimg-api-client
**Story**: N/A
**Epic**: N/A
**Status**: In Progress
**Priority**: High
**Branch**: feat/T-2026-003-floimg-api-client
**Created**: 2026-01-15
**Started**: 2026-01-15
**Completed**:

## Description
Create an HTTP client module for bots to interact with the FloImg gallery API. This client will be used by BotAgent to perform actual actions like posting images, liking content, leaving comments, and browsing the gallery.

The API endpoints don't fully exist yet, so this will define the expected interface that FloImg's API should implement.

## Checklist
- [ ] Create `FloimgFleet.FloImgAPI` module with Req-based HTTP client
- [ ] Implement gallery endpoints (list, get, create post)
- [ ] Implement interaction endpoints (like, comment)
- [ ] Implement browse/discover endpoints
- [ ] Add authentication handling (bot tokens)
- [ ] Wire up BotAgent to use the API client
- [ ] Add configuration for API base URL and credentials

## Technical Details
### Approach
- Use Req for HTTP requests (already in deps)
- Define clear interface that documents expected API shape
- Return tagged tuples for error handling
- Support both real API calls and mock mode for testing

### Expected API Endpoints (imagined)
```
POST   /api/gallery/posts      - Create a new post
GET    /api/gallery/posts      - List posts (with pagination)
GET    /api/gallery/posts/:id  - Get single post
POST   /api/gallery/posts/:id/like    - Like a post
DELETE /api/gallery/posts/:id/like    - Unlike a post
POST   /api/gallery/posts/:id/comments - Add comment
GET    /api/gallery/feed       - Get personalized feed
```

### Files to Create
- `lib/floimg_fleet/floimg_api.ex` - Main API client module
- `lib/floimg_fleet/floimg_api/gallery.ex` - Gallery-related endpoints
- `lib/floimg_fleet/floimg_api/auth.ex` - Authentication handling

### Configuration
```elixir
config :floimg_fleet, FloimgFleet.FloImgAPI,
  base_url: "https://api.floimg.com",
  bot_secret: System.get_env("FLOIMG_BOT_SECRET")
```

## Dependencies
### Blocked By
- None

### Blocks
- Bot actions (bots need API client to actually do things)

## Context
See [[T-2026-003-context]] for detailed implementation notes.

## Notes
- API shape is speculative - will need to align with actual FloImg API
- Consider adding retry logic for transient failures
- Log all API calls for debugging/analytics
