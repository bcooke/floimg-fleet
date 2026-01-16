# Context: T-2026-003 FloImg API Client

**Task**: [[T-2026-003-floimg-api-client]]
**Created**: 2026-01-15
**Status**: Planning

## Overview

Create the HTTP client that bots use to interact with FloImg's gallery API. Since the API doesn't fully exist yet, this task defines the expected interface - essentially a contract that FloImg's API should implement.

## Imagined API Shape

Based on what bots need to do:

### Gallery Posts
```
POST /api/gallery/posts
  Body: { image_url, caption, workflow_id? }
  Response: { id, image_url, caption, created_at, author }

GET /api/gallery/posts
  Query: ?page=1&per_page=20&sort=recent|popular
  Response: { posts: [...], meta: { total, page, per_page } }

GET /api/gallery/posts/:id
  Response: { id, image_url, caption, likes_count, comments_count, ... }
```

### Interactions
```
POST /api/gallery/posts/:id/like
  Response: { liked: true, likes_count }

DELETE /api/gallery/posts/:id/like
  Response: { liked: false, likes_count }

POST /api/gallery/posts/:id/comments
  Body: { content }
  Response: { id, content, author, created_at }
```

### Discovery
```
GET /api/gallery/feed
  Query: ?page=1
  Response: { posts: [...] }  # Personalized feed

GET /api/gallery/trending
  Response: { posts: [...] }  # Popular content
```

### Authentication
Bots authenticate with a special bot token:
```
Authorization: Bearer bot_{token}
X-Bot-ID: {bot_uuid}
```

## Module Structure

```elixir
FloimgFleet.FloImgAPI
├── Gallery      # Post CRUD, feed, trending
├── Interactions # Like, comment
└── Auth         # Token handling
```

## Integration with BotAgent

Current BotAgent has placeholder functions:
- `do_post/1` → will call `FloImgAPI.Gallery.create_post/2`
- `do_comment/1` → will call `FloImgAPI.Interactions.add_comment/3`
- `do_like/1` → will call `FloImgAPI.Interactions.like_post/2`
- `do_browse/1` → will call `FloImgAPI.Gallery.get_feed/1`

## Open Questions

- What authentication method will FloImg API use for bots?
- Should bots have their own user accounts or a shared bot identity?
- Rate limiting strategy for bot requests?

## Next Steps

1. Run `/s T-2026-003` to start work
2. Create the API client module structure
3. Implement imagined endpoints
4. Wire up to BotAgent
