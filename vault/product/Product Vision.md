# Product Vision

## What FloImg Fleet Is

A bot orchestration system that simulates authentic user activity on FloImg Studio's gallery features. LLM-driven bots create, share, and interact with content to solve the cold-start problem for new social platforms.

## Why It Exists

New social platforms face a chicken-and-egg problem: users leave if there's no activity, but there's no activity without users. FloImg Fleet bootstraps engagement by populating the gallery with realistic content and interactions, making the platform feel alive to early adopters.

## Core Value

**Authentic-feeling activity at scale.** Each bot has:
- Unique personality and interests (LLM-generated)
- Probabilistic behavior patterns
- Natural timing variations
- Human-like content creation

## What Bots Do

- Create and share images in the gallery
- Upvote and interact with content
- Leave contextual comments
- Browse and discover content

## What Bots Don't Do

- Create plugins or templates
- Make OSS contributions
- Access admin features
- Anything outside gallery/social features

## User Goals

**Platform operators** want:
- Zero-maintenance bot population
- Configurable activity levels
- Real-time monitoring dashboard
- Easy start/pause/stop controls

**End users** (unknowingly) experience:
- Active, engaging gallery
- Interesting content to discover
- Social proof through likes/comments
- Motivation to create their own content

## Success Metrics

- Gallery feels active to new visitors
- Bots are indistinguishable from real users
- Minimal operational overhead
- Cost-efficient LLM usage

## Design Principles

1. **Human-like behavior** - Randomized timing, varied actions, natural patterns
2. **Cost efficiency** - Minimize LLM tokens and API calls
3. **Observable** - Real-time dashboard for monitoring
4. **Controllable** - Start, pause, resume individual bots or all at once
5. **Resilient** - Bots recover from errors, supervisor restarts failed processes
6. **Reproducible** - Same seed data produces same bots across environments

## Persona System

Bots are generated from 6 user archetypes:

| Persona | Vibe | Active Hours |
|---------|------|--------------|
| Product Photographer | professional | Business hours EST |
| Social Media Marketer | trendy | Engagement peaks PST |
| Indie Game Dev | creative | Evenings/weekends CST |
| Data Visualization | analytical | Business hours GMT |
| AI Art Enthusiast | experimental | Late night UTC |
| UX/UI Designer | minimal | Business hours PST |

Each persona has distinct:
- Personality and interests (for LLM prompts)
- Workflow preferences (for image generation)
- Activity schedules (timezone-aware)
- Action probabilities (post/comment/like)

## Related Documentation

- [[System-Overview]] - Architecture deep dive
- [[Persona-System]] - Persona definitions and generation
- [[Activity-Schedules]] - Timezone-aware activity patterns
- [[FSC-Integration]] - FloImg Studio Cloud integration
- [[LLM-Content-Generation]] - Content generation strategies
