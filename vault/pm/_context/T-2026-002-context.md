# Context: T-2026-002 Admin Panel LiveView

**Task**: [[T-2026-002-admin-panel-liveview]]
**Created**: 2026-01-15
**Status**: Planning

## Overview

Build a LiveView admin panel for bot management. The panel provides:
- List view of all bots with status indicators
- Individual bot detail/edit view
- Start/pause/resume controls
- Real-time activity feed

## Key Components

### BotLive.Index
Main dashboard showing all bots in a table:
- Name, username, status (idle/running/paused/error)
- Action buttons: Start, Pause, Delete
- Bulk controls: Pause All, Resume All
- Real-time status updates via PubSub

### BotLive.Show
Individual bot detail view:
- Full bot configuration display
- Edit form for personality, probabilities, intervals
- Activity history for this bot
- Start/pause controls

### Activity Feed
Sidebar or panel showing real-time bot activity:
- Subscribed to `fleet:activity` PubSub topic
- Shows: bot name, action type, timestamp
- Auto-scrolls to latest
- Clickable to navigate to bot

## LiveView Patterns

### PubSub Integration
```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(FloimgFleet.PubSub, "fleet:activity")
  end
  {:ok, assign(socket, bots: Bots.list_bots())}
end

def handle_info({:bot_activity, activity}, socket) do
  {:noreply, stream_insert(socket, :activities, activity)}
end
```

### Action Handlers
```elixir
def handle_event("start", %{"id" => id}, socket) do
  case Bots.start_bot(id) do
    {:ok, _} -> {:noreply, put_flash(socket, :info, "Bot started")}
    {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
  end
end
```

## UI Components

Using DaisyUI classes already in the project:
- `table` for bot list
- `badge` for status indicators (idle=gray, running=green, paused=yellow, error=red)
- `btn` for actions
- `card` for activity feed container

## Open Questions

- Should activity feed be on every page or just index?
- How many activities to show in feed (paginate or limit)?
- Add bot creation form or separate page?

## Next Steps

1. Run `/s T-2026-002` to start work
2. Create LiveView module structure
3. Implement index view with bot list
4. Add PubSub subscription for real-time updates
5. Implement action handlers
6. Add show view with edit form
