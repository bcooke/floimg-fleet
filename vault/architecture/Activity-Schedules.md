# Activity Schedules

Bots operate on timezone-aware schedules that match their persona's realistic behavior patterns.

## Purpose

Real users have activity patterns:
- Professionals work during business hours
- Social media marketers post during engagement peaks
- Hobbyists are active evenings and weekends

Bots mirror these patterns for authenticity.

## Schedule Definition

Each persona includes an `activity_schedule` in `personas.json`:

```json
"activity_schedule": {
  "peak_hours": [[9, 12], [13, 17]],
  "active_days": [1, 2, 3, 4, 5],
  "timezone": "America/New_York",
  "peak_multiplier": 2.0,
  "off_peak_multiplier": 0.3
}
```

| Field | Description |
|-------|-------------|
| `peak_hours` | Array of [start, end] hour ranges (24h) |
| `active_days` | Days of week (0=Sunday, 6=Saturday) |
| `timezone` | IANA timezone for local time calculation |
| `peak_multiplier` | Speed multiplier during peak hours |
| `off_peak_multiplier` | Speed multiplier off-peak |

## Persona Schedules

| Persona | Active Days | Peak Hours | Timezone |
|---------|-------------|------------|----------|
| Product Photographer | Mon-Fri | 9-12, 1-5pm | EST |
| Social Media Marketer | All week | 7-9am, 12-2pm, 6-10pm | PST |
| Indie Game Dev | Fri-Sun | 6pm-2am | CST |
| Data Visualization | Mon-Fri | 8am-12, 2-6pm | GMT |
| AI Art Enthusiast | All week | 8pm-4am | UTC |
| UX/UI Designer | Mon-Fri | 9am-12, 2-6pm | PST |

## How Multipliers Work

The activity multiplier affects action intervals:

```
actual_delay = base_delay / multiplier
```

- **Peak hours on active days**: `peak_multiplier` (2.0x = twice as fast)
- **Non-peak on active days**: 1.0x (normal speed)
- **Inactive days/hours**: `off_peak_multiplier` (0.3x = much slower)

Minimum delay is enforced at 5 seconds to prevent API hammering.

## Implementation

```elixir
# Get current multiplier for a persona
Seeds.get_activity_multiplier("product_photographer")
# => 2.0 (if during EST business hours)
# => 0.3 (if weekend/night)

# Used in BotAgent.schedule_next_action/1
multiplier = Seeds.get_activity_multiplier(bot.persona_id)
delay = max(5_000, round(base_delay / multiplier))
```

## Timezone Handling

Uses Elixir's `DateTime.shift_zone/2` with timezone database:

```elixir
defp convert_to_timezone(datetime, timezone) do
  case DateTime.shift_zone(datetime, timezone) do
    {:ok, local} -> local
    {:error, reason} ->
      Logger.warning("Invalid timezone: #{timezone}")
      datetime  # Fallback to UTC
  end
end
```

## Midnight Wraparound

Peak hours can span midnight (e.g., AI artists 8pm-4am):

```elixir
# [20, 4] means 8pm to 4am
defp in_hour_range?(hour, start_hour, end_hour) when end_hour < start_hour do
  hour >= start_hour or hour < end_hour
end
```

## Related Documents

- [[Persona-System]] - Persona definitions
- [[System-Overview]] - Architecture overview
