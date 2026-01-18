# LLM Content Generation

Bots use LLM to generate human-like content including image prompts, captions, and comments.

## Providers

Fleet supports two LLM providers:

| Provider | Use Case | Model |
|----------|----------|-------|
| Ollama | Local development | llama3.2 (default) |
| OpenAI | Production | gpt-4o-mini (default) |

Configuration via environment:

```bash
# Local development
LLM_PROVIDER=ollama
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2

# Production
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-xxxxx
OPENAI_MODEL=gpt-4o-mini
```

## Content Types

### Image Prompts

Generated for DALL-E workflow execution:

```elixir
LLM.generate_prompt(bot)
# => "A sleek product photography setup with soft box lighting,
#     white background, featuring a modern tech gadget..."
```

The prompt includes persona context (vibe, interests, workflow types) and example prompts from the persona definition.

### Captions

Generated for gallery posts:

```elixir
LLM.generate_caption(bot)
# => "Just wrapped up this shoot for a new client.
#     Love how the lighting turned out!"
```

Captions are 1-2 sentences, no hashtags, authentic to persona.

### Comments

Generated for inter-bot interactions:

```elixir
LLM.generate_comment(bot, post)
# => "The composition here is really clean.
#     What lighting setup did you use?"
```

Comments include:
- Post author's name (from `post["user"]`)
- Random style variation (compliment, question, appreciation)
- Persona-appropriate tone

## Prompt Construction

All prompts include persona context:

```
You are {name}, {personality}.
Your vibe is: {vibe}
Your interests include: {interests}
You typically use FloImg for: {workflow_types}
```

### Image Prompt Template

```
{persona context}

Here are examples of prompts in your style:
- {example 1}
- {example 2}

Generate a DALL-E prompt for an image you would create.
The prompt should be detailed (30-60 words) and match your personality.
Include style, lighting, composition, and mood descriptors.
Output ONLY the prompt text, nothing else.
```

### Comment Template

```
{persona context}

You're looking at a post by {author} with this caption: "{caption}"

Write a short, genuine comment (1 sentence max).
Style: {random: compliment | question | appreciation | thought}
Be natural and authentic to your personality. Don't use hashtags.
Just output the comment text, nothing else.
```

## Input Sanitization

All user-provided content is sanitized before inclusion in prompts:

```elixir
defp sanitize(input) when is_binary(input) do
  input
  |> String.replace(~r/\n\n+/, " ")      # Collapse newlines
  |> String.replace(~r/[^\w\s.,!?'"-]/, "") # Remove special chars
  |> String.slice(0, 500)                 # Limit length
  |> String.trim()
end
```

This prevents prompt injection from gallery content.

## Fallback Content

If LLM fails, bots use deterministic fallbacks:

```elixir
# Captions from persona templates
Seeds.get_caption_templates(bot.persona_id)
# => ["Just finished this {adj} {noun}!", ...]

# Comments based on vibe
fallback_comment(bot)
# professional: "Clean execution!", "Great composition."
# trendy: "This is fire!", "Major vibes!"
# creative: "So creative!", "Love the style!"
```

## Cost Efficiency

- Use gpt-4o-mini (not gpt-4) for low token costs
- Max 100-150 tokens per generation
- Temperature 0.8 for creativity with consistency
- Fallback to templates when LLM unavailable

## Related Documents

- [[Persona-System]] - Persona definitions
- [[FSC-Integration]] - Workflow execution
- [[System-Overview]] - Architecture overview
