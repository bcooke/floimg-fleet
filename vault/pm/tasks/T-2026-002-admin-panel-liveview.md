---
type: task
id: T-2026-002
story:
epic:
status: completed
priority: high
created: 2026-01-15
updated: 2026-01-15
---

# Task: Admin Panel LiveView

## Task Details
**Task ID**: T-2026-002-admin-panel-liveview
**Story**: N/A
**Epic**: N/A
**Status**: Completed
**Priority**: High
**Branch**: feat/T-2026-002-admin-panel-liveview
**Created**: 2026-01-15
**Started**: 2026-01-15
**Completed**: 2026-01-15

## Description
Build a LiveView-based admin panel for managing bots. The dashboard provides real-time visibility into bot activity and controls for starting, pausing, and resuming bots individually or in bulk.

## Checklist
- [x] Create BotLive.Index LiveView for bot list with real-time updates
- [x] Create BotLive.Show LiveView for individual bot detail view
- [x] Implement start/pause/resume controls for individual bots
- [x] Implement pause-all/resume-all bulk controls
- [x] Add real-time activity feed via PubSub subscription
- [x] Style with existing DaisyUI components

## Technical Details
### Approach
- Use Phoenix LiveView for real-time updates without page refresh
- Subscribe to `fleet:activity` PubSub channel for live updates
- Use existing CQRS commands (StartBot, PauseBot, etc.) for actions
- Leverage BotSupervisor for runtime state queries

### Files to Create/Modify
- `lib/floimg_fleet_web/live/bot_live/index.ex` - Bot list view
- `lib/floimg_fleet_web/live/bot_live/index.html.heex` - Bot list template
- `lib/floimg_fleet_web/live/bot_live/show.ex` - Bot detail view
- `lib/floimg_fleet_web/live/bot_live/show.html.heex` - Bot detail template
- `lib/floimg_fleet_web/live/bot_live/form_component.ex` - Create/edit bot form
- `lib/floimg_fleet_web/router.ex` - Add LiveView routes

### Testing Required
- [ ] LiveView renders bot list correctly
- [ ] Start/pause/resume actions update UI in real-time
- [ ] PubSub activity feed displays new events
- [ ] Bulk actions affect all running bots

### Documentation Updates
- Update vault architecture docs with admin panel section

## Dependencies
### Blocked By
- None (T-2026-001 completed)

### Blocks
- FloImg API client integration (bots need actions to perform)

## Context
See [[T-2026-002-context]] for detailed implementation notes.

## Notes
- Follow Phoenix LiveView 1.0 patterns
- Use function components for reusable UI elements
- Activity feed should auto-scroll to show latest events
