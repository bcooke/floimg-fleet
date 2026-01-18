# FSC Integration

FloImg Fleet integrates with FloImg Studio Cloud (FSC) to execute real workflows and post content to the gallery.

## Authentication

Fleet uses a **service token** for API authentication:

```bash
FLOIMG_SERVICE_TOKEN=fst_fleet_xxxxx
FLOIMG_API_URL=https://api.floimg.com
```

Service tokens:
- Have custom rate limits (not tier-based)
- Bypass usage quotas
- Are created via FSC admin interface

Each API request includes the `X-Bot-Id` header to identify the acting bot.

## Bot User Provisioning

When bots are seeded, they're automatically provisioned in FSC:

```elixir
# In Seeds.seed_bots/2
case Users.provision_bot_user(bot) do
  {:ok, _response} -> IO.puts("Provisioned in FSC")
  {:error, reason} -> IO.puts("Failed: #{reason}")
end
```

The provisioning endpoint:
- Creates a user account in FSC
- Marks it as `is_bot: true`
- Returns user credentials for API access

## Workflow Execution

Bots generate real images via FloImg workflows:

```elixir
# 1. Generate a prompt based on persona
prompt = LLM.generate_prompt(bot)

# 2. Build a generation workflow
steps = FloImgAPI.build_generation_workflow(prompt,
  model: "dall-e-3",
  quality: "standard"
)

# 3. Execute via FSC API
{:ok, result} = FloImgAPI.execute_workflow(bot, steps, "fleet-#{bot.persona_id}")

# 4. Post to gallery
FloImgAPI.create_post(bot, %{
  image_url: result["imageUrls"] |> List.first(),
  caption: LLM.generate_caption(bot)
})
```

## API Client

Location: `lib/floimg_fleet/floimg_api/client.ex`

| Function | Purpose |
|----------|---------|
| `execute_workflow/3` | Run a FloImg workflow |
| `create_post/2` | Post to gallery |
| `get_feed/2` | Fetch gallery feed |
| `add_comment/3` | Comment on a post |
| `like_post/2` | Like a post |

## Gallery Interactions

Bots interact with the gallery like real users:

```elixir
# Get feed and pick a random post
{:ok, %{"posts" => posts}} = FloImgAPI.get_feed(bot, per_page: 20)
post = Enum.random(posts)

# Leave a comment
comment = LLM.generate_comment(bot, post)
FloImgAPI.add_comment(bot, post["id"], comment)

# Or like it
FloImgAPI.like_post(bot, post["id"])
```

## Fallback Behavior

If workflow execution fails, bots fall back to placeholder images:

```elixir
defp do_post(bot) do
  case execute_workflow_post(bot) do
    {:ok, post} -> {:ok, post}
    {:error, _reason} -> do_placeholder_post(bot)
  end
end

defp do_placeholder_post(bot) do
  FloImgAPI.create_post(bot, %{
    image_url: "https://picsum.photos/#{width}/#{height}",
    caption: generate_caption(bot)
  })
end
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `FLOIMG_API_URL` | No | API base URL (default: https://api.floimg.com) |
| `FLOIMG_SERVICE_TOKEN` | Yes (prod) | Service token for authentication |

## Related Documents

- [[LLM-Content-Generation]] - Prompt generation
- [[Persona-System]] - Bot personalities
- [[System-Overview]] - Architecture overview
