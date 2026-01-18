# Persona System

The persona system enables deterministic bot generation from predefined user archetypes.

## Purpose

Instead of randomly generating bots or manually configuring each one:
- Define personas once in JSON
- Generate reproducible bots (same seed = same bots)
- No LLM calls needed for bot identity generation
- Realistic personalities anchored to actual FloImg user types

## Personas File

Location: `priv/seeds/personas.json`

```json
{
  "personas": [
    {
      "id": "product_photographer",
      "name_templates": ["{adj} Studio", "{adj} Lens Pro"],
      "username_prefix": "studio_",
      "personality": "Professional product photographer...",
      "vibe": "professional",
      "interests": ["product photography", "e-commerce"],
      "probabilities": { "post": 0.7, "comment": 0.4, "like": 0.8 },
      "workflow_types": ["background_removal", "shadow_add"],
      "weight": 1.5,
      "activity_schedule": { ... }
    }
  ],
  "adjectives": ["Bright", "Clear", "Crisp"],
  "nouns": ["Pro", "Studio", "Lab"]
}
```

## The 6 Archetypes

| Persona | ID | Vibe | Weight |
|---------|----|----|--------|
| Product Photographer | `product_photographer` | professional | 1.5 |
| Social Media Marketer | `social_media_marketer` | trendy | 2.0 |
| Indie Game Dev | `indie_game_dev` | creative | 1.0 |
| Data Visualization | `data_viz` | analytical | 0.8 |
| AI Art Enthusiast | `ai_artist` | experimental | 1.5 |
| UX/UI Designer | `ux_designer` | minimal | 1.0 |

**Weight** determines selection probability when generating diverse swarms.

## Deterministic Generation

Bot names are generated deterministically from persona + index:

```elixir
Seeds.generate_bot_from_persona(persona, index)
```

The same persona + index always produces the same:
- Name (from templates + adjectives/nouns)
- Username
- Personality traits

This enables reproducibility across environments.

## Key Modules

| Module | Purpose |
|--------|---------|
| `FloimgFleet.Seeds` | Load personas, generate bots |
| `FloimgFleet.Seeds.load_personas/0` | Parse personas.json |
| `FloimgFleet.Seeds.generate_bot_from_persona/2` | Create bot attrs |
| `FloimgFleet.Seeds.weighted_random_persona/1` | Select by weight |

## Usage

```elixir
# Seed 6 bots with weighted distribution
mix fleet.seed_bots --count 6

# Seed 3 product photographers
mix fleet.seed_bots --count 3 --persona product_photographer

# Programmatic seeding
FloimgFleet.Seeds.seed_bots(10, persona: "ai_artist")
```

## Related Documents

- [[Activity-Schedules]] - Per-persona timing
- [[LLM-Content-Generation]] - Persona context in prompts
- [[System-Overview]] - Architecture overview
