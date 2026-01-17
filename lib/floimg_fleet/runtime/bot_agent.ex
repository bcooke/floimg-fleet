defmodule FloimgFleet.Runtime.BotAgent do
  @moduledoc """
  GenServer for an individual bot.

  Each bot agent manages its own lifecycle:
  - Subscribes to the activity feed
  - Periodically decides on actions (post, comment, like, browse)
  - Logs activity to the database and broadcasts via PubSub

  ## State

  The agent maintains:
  - `bot`: The bot configuration from database
  - `last_action`: The last action taken
  - `paused`: Whether the bot is paused

  ## Lifecycle

  1. `init/1` - Subscribes to PubSub, broadcasts "waking up"
  2. `:think` - Decides next action based on probabilities
  3. `:post/:comment/:like/:browse` - Executes the action
  4. `:sleep` - Stops the agent gracefully

  """

  use GenServer, restart: :transient

  alias FloimgFleet.Bots
  alias FloimgFleet.Bots.Schemas.Bot
  alias FloimgFleet.FloImgAPI
  alias FloimgFleet.LLM.Client, as: LLM

  require Logger

  # PubSub channel for activity broadcasts
  @channel "fleet:activity"

  # How often to think about next action (ms)
  @default_think_delay 5_000

  # ============================================================================
  # Client API
  # ============================================================================

  def start_link(%Bot{} = bot) do
    GenServer.start_link(__MODULE__, bot)
  end

  def pause(pid) do
    GenServer.cast(pid, :pause)
  end

  def resume(pid) do
    GenServer.cast(pid, :resume)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  # ============================================================================
  # Server Callbacks
  # ============================================================================

  @impl true
  def init(bot) do
    # Subscribe to the activity channel
    Phoenix.PubSub.subscribe(FloimgFleet.PubSub, @channel)

    # Update bot status in database
    update_bot_status(bot, :running, self())

    # Broadcast that we're waking up
    broadcast(:started, "Waking up!", bot)

    # Schedule first think
    schedule_think(@default_think_delay)

    {:ok, %{bot: bot, last_action: nil, paused: false}}
  end

  @impl true
  def handle_info(:think, %{paused: true} = state) do
    # If paused, just reschedule
    schedule_think(@default_think_delay)
    {:noreply, state}
  end

  def handle_info(:think, %{bot: bot} = state) do
    action = decide_action(bot)
    broadcast(:thought, "I want to #{action}", bot)

    # Schedule the action
    Process.send_after(self(), action, 1_000)
    {:noreply, state}
  end

  def handle_info(:post, %{bot: bot} = state) do
    broadcast(:action, "Creating a new post...", bot)

    case do_post(bot) do
      {:ok, post} ->
        broadcast(:post, "Posted a new image: #{post["caption"] || "untitled"}", bot)

      {:error, reason} ->
        broadcast(:error, "Failed to post: #{inspect(reason)}", bot)
    end

    schedule_next_action(bot)
    {:noreply, %{state | last_action: :post}}
  end

  def handle_info(:comment, %{bot: bot} = state) do
    broadcast(:action, "Looking for something to comment on...", bot)

    case do_comment(bot) do
      {:ok, _comment} ->
        broadcast(:comment, "Left a comment!", bot)

      {:error, :no_posts} ->
        broadcast(:thought, "Nothing to comment on", bot)

      {:error, reason} ->
        broadcast(:error, "Failed to comment: #{inspect(reason)}", bot)
    end

    schedule_next_action(bot)
    {:noreply, %{state | last_action: :comment}}
  end

  def handle_info(:like, %{bot: bot} = state) do
    broadcast(:action, "Scrolling the feed...", bot)

    case do_like(bot) do
      {:ok, _result} ->
        broadcast(:like, "Liked a post!", bot)

      {:error, :no_posts} ->
        broadcast(:thought, "Nothing to like", bot)

      {:error, reason} ->
        broadcast(:error, "Failed to like: #{inspect(reason)}", bot)
    end

    schedule_next_action(bot)
    {:noreply, %{state | last_action: :like}}
  end

  def handle_info(:browse, %{bot: bot} = state) do
    broadcast(:thought, "Just browsing...", bot)

    case do_browse(bot) do
      {:ok, posts} ->
        count = length(posts["posts"] || [])
        broadcast(:thought, "Found #{count} posts in feed", bot)

      {:error, _reason} ->
        :ok
    end

    schedule_next_action(bot)
    {:noreply, %{state | last_action: :browse}}
  end

  def handle_info(:sleep, %{bot: bot} = state) do
    broadcast(:stopped, "Going to sleep...", bot)
    update_bot_status(bot, :idle, nil)

    {:stop, :normal, state}
  end

  # Ignore PubSub messages from other bots
  def handle_info({:activity, _, _}, state), do: {:noreply, state}

  @impl true
  def handle_cast(:pause, %{bot: bot} = state) do
    broadcast(:paused, "Pausing...", bot)
    update_bot_status(bot, :paused, self())

    {:noreply, %{state | paused: true}}
  end

  def handle_cast(:resume, %{bot: bot} = state) do
    broadcast(:started, "Resuming!", bot)
    update_bot_status(bot, :running, self())

    {:noreply, %{state | paused: false}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def terminate(_reason, %{bot: bot}) do
    update_bot_status(bot, :idle, nil)
    :ok
  end

  # ============================================================================
  # API Actions
  # ============================================================================

  defp do_post(bot) do
    # Generate a post with random image and caption
    # In a real implementation, this would use an LLM to generate content
    attrs = %{
      image_url: generate_placeholder_image(),
      caption: generate_caption(bot)
    }

    FloImgAPI.create_post(bot, attrs)
  end

  defp do_comment(bot) do
    # Get feed, pick a random post, leave a comment
    case FloImgAPI.get_feed(bot, per_page: 20) do
      {:ok, %{"posts" => posts}} when posts != [] ->
        post = Enum.random(posts)
        comment = generate_comment(bot, post)
        FloImgAPI.add_comment(bot, post["id"], comment)

      {:ok, _} ->
        {:error, :no_posts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_like(bot) do
    # Get feed, pick a random post, like it
    case FloImgAPI.get_feed(bot, per_page: 20) do
      {:ok, %{"posts" => posts}} when posts != [] ->
        post = Enum.random(posts)
        FloImgAPI.like_post(bot, post["id"])

      {:ok, _} ->
        {:error, :no_posts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_browse(bot) do
    FloImgAPI.get_feed(bot, per_page: 20)
  end

  defp generate_placeholder_image do
    # Generate a placeholder image URL
    # In production, this would be an actual generated image
    width = Enum.random([512, 768, 1024])
    height = Enum.random([512, 768, 1024])
    "https://picsum.photos/#{width}/#{height}"
  end

  defp generate_caption(bot) do
    case LLM.generate_caption(bot) do
      {:ok, caption} ->
        caption

      {:error, _reason} ->
        # Fallback to simple generation
        fallback_caption(bot)
    end
  end

  defp generate_comment(bot, post) do
    case LLM.generate_comment(bot, post) do
      {:ok, comment} ->
        comment

      {:error, _reason} ->
        # Fallback to simple generation
        fallback_comment(bot)
    end
  end

  defp fallback_caption(bot) do
    captions = [
      "Check out what I made!",
      "Just experimenting with some new ideas",
      "Love how this turned out",
      "Playing around with different styles",
      "What do you think?",
      "#{bot.vibe || "Feeling creative"} vibes today"
    ]

    Enum.random(captions)
  end

  defp fallback_comment(bot) do
    comments = [
      "This is amazing!",
      "Love the style!",
      "Great work!",
      "So creative!",
      "Wow, this is cool",
      "Really nice composition",
      "The colors are perfect",
      "#{bot.vibe || "Nice"} work!"
    ]

    Enum.random(comments)
  end

  # ============================================================================
  # Private Functions
  # ============================================================================

  defp decide_action(bot) do
    # Weighted random selection based on bot's probabilities
    rand = :rand.uniform()

    cond do
      rand < bot.post_probability -> :post
      rand < bot.post_probability + bot.comment_probability -> :comment
      rand < bot.post_probability + bot.comment_probability + bot.like_probability -> :like
      true -> :browse
    end
  end

  defp schedule_think(delay) do
    Process.send_after(self(), :think, delay)
  end

  defp schedule_next_action(bot) do
    delay =
      Enum.random(
        (bot.min_action_interval_seconds * 1_000)..(bot.max_action_interval_seconds * 1_000)
      )

    schedule_think(delay)
  end

  defp broadcast(event_type, message, bot) do
    activity = %{
      bot_id: bot.id,
      bot_name: bot.name,
      event_type: event_type,
      message: message,
      emoji: emoji_for(event_type),
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(FloimgFleet.PubSub, @channel, {:activity, event_type, activity})

    Logger.info("[#{bot.name}] #{emoji_for(event_type)} #{message}")
  end

  defp emoji_for(:started), do: "🌅"
  defp emoji_for(:stopped), do: "💤"
  defp emoji_for(:paused), do: "⏸️"
  defp emoji_for(:thought), do: "💭"
  defp emoji_for(:action), do: "🎬"
  defp emoji_for(:post), do: "📸"
  defp emoji_for(:comment), do: "💬"
  defp emoji_for(:like), do: "❤️"
  defp emoji_for(:error), do: "❌"
  defp emoji_for(_), do: "•"

  defp update_bot_status(bot, status, pid) do
    pid_string = if pid, do: inspect(pid), else: nil

    # Update in database (fire and forget for now)
    Task.start(fn ->
      Bots.update_bot(bot.id, %{status: status, pid: pid_string})
    end)
  end
end
