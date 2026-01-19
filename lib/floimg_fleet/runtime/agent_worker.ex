defmodule FloimgFleet.Runtime.AgentWorker do
  @moduledoc """
  GenServer for an individual agent.

  Each agent manages its own lifecycle:
  - Subscribes to the activity feed
  - Periodically decides on actions (post, comment, like, browse)
  - Logs activity to the database and broadcasts via PubSub

  ## State

  The agent maintains:
  - `agent`: The agent configuration from database
  - `last_action`: The last action taken
  - `paused`: Whether the agent is paused

  ## Lifecycle

  1. `init/1` - Subscribes to PubSub, broadcasts "waking up"
  2. `:think` - Decides next action based on probabilities
  3. `:post/:comment/:like/:browse` - Executes the action
  4. `:sleep` - Stops the agent gracefully

  """

  use GenServer, restart: :transient

  alias FloimgFleet.Agents
  alias FloimgFleet.Agents.Schemas.Agent
  alias FloimgFleet.FloImgAPI
  alias FloimgFleet.LLM.Client, as: LLM
  alias FloimgFleet.Seeds

  require Logger

  # PubSub channel for activity broadcasts
  @channel "fleet:activity"

  # How often to think about next action (ms)
  @default_think_delay 5_000

  # ============================================================================
  # Client API
  # ============================================================================

  def start_link(%Agent{} = agent) do
    GenServer.start_link(__MODULE__, agent)
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
  def init(agent) do
    # Subscribe to the activity channel
    Phoenix.PubSub.subscribe(FloimgFleet.PubSub, @channel)

    # Update agent status in database
    update_agent_status(agent, :running, self())

    # Broadcast that we're waking up
    broadcast(:started, "Waking up!", agent)

    # Schedule first think
    schedule_think(@default_think_delay)

    {:ok, %{agent: agent, last_action: nil, paused: false}}
  end

  @impl true
  def handle_info(:think, %{paused: true} = state) do
    # If paused, just reschedule
    schedule_think(@default_think_delay)
    {:noreply, state}
  end

  def handle_info(:wake, %{agent: agent} = state) do
    # Resume from budget-limited sleep
    broadcast(:started, "Waking up from budget sleep!", agent)
    update_agent_status(agent, :running, self())
    schedule_think(@default_think_delay)
    {:noreply, %{state | paused: false}}
  end

  def handle_info(:think, %{agent: agent} = state) do
    action = decide_action(agent)
    broadcast(:thought, "I want to #{action}", agent)

    # Schedule the action
    Process.send_after(self(), action, 1_000)
    {:noreply, state}
  end

  def handle_info(:post, %{agent: agent} = state) do
    broadcast(:action, "Creating a new post...", agent)

    case do_post(agent) do
      {:ok, post} ->
        broadcast(:post, "Posted a new image: #{post["caption"] || "untitled"}", agent)
        schedule_next_action(agent)
        {:noreply, %{state | last_action: :post}}

      # Fleet budget errors - pause or wait
      {:error, {:fleet_paused, reason}} ->
        broadcast(:paused, "Fleet paused: #{reason}", agent)
        update_agent_status(agent, :paused, self())
        {:noreply, %{state | paused: true}}

      {:error, {:fleet_daily_budget, reset_at}} ->
        broadcast(:thought, "Fleet daily budget reached, sleeping until reset...", agent)
        schedule_wake_at(reset_at)
        update_agent_status(agent, :paused, self())
        {:noreply, %{state | paused: true}}

      {:error, {:fleet_monthly_budget, reset_at}} ->
        broadcast(:thought, "Fleet monthly budget reached, sleeping until next month...", agent)
        schedule_wake_at(reset_at)
        update_agent_status(agent, :paused, self())
        {:noreply, %{state | paused: true}}

      {:error, {:agent_daily_limit, body}} ->
        used = get_in(body, ["usage", "used"]) || "?"
        limit = get_in(body, ["usage", "limit"]) || "?"
        reset_at = body["resetAt"]

        broadcast(
          :thought,
          "Daily limit reached (#{used}/#{limit}), sleeping until reset...",
          agent
        )

        schedule_wake_at(reset_at)
        update_agent_status(agent, :paused, self())
        {:noreply, %{state | paused: true}}

      {:error, {:agent_monthly_limit, body}} ->
        used = get_in(body, ["usage", "used"]) || "?"
        limit = get_in(body, ["usage", "limit"]) || "?"
        reset_at = body["resetAt"]

        broadcast(
          :thought,
          "Monthly limit reached (#{used}/#{limit}), sleeping until next month...",
          agent
        )

        schedule_wake_at(reset_at)
        update_agent_status(agent, :paused, self())
        {:noreply, %{state | paused: true}}

      {:error, reason} ->
        broadcast(:error, "Failed to post: #{inspect(reason)}", agent)
        schedule_next_action(agent)
        {:noreply, %{state | last_action: :post}}
    end
  end

  def handle_info(:comment, %{agent: agent} = state) do
    broadcast(:action, "Looking for something to comment on...", agent)

    case do_comment(agent) do
      {:ok, _comment} ->
        broadcast(:comment, "Left a comment!", agent)

      {:error, :no_posts} ->
        broadcast(:thought, "Nothing to comment on", agent)

      {:error, reason} ->
        broadcast(:error, "Failed to comment: #{inspect(reason)}", agent)
    end

    schedule_next_action(agent)
    {:noreply, %{state | last_action: :comment}}
  end

  def handle_info(:like, %{agent: agent} = state) do
    broadcast(:action, "Scrolling the feed...", agent)

    case do_like(agent) do
      {:ok, _result} ->
        broadcast(:like, "Liked a post!", agent)

      {:error, :no_posts} ->
        broadcast(:thought, "Nothing to like", agent)

      {:error, reason} ->
        broadcast(:error, "Failed to like: #{inspect(reason)}", agent)
    end

    schedule_next_action(agent)
    {:noreply, %{state | last_action: :like}}
  end

  def handle_info(:browse, %{agent: agent} = state) do
    broadcast(:thought, "Just browsing...", agent)

    case do_browse(agent) do
      {:ok, posts} ->
        count = length(posts["posts"] || [])
        broadcast(:thought, "Found #{count} posts in feed", agent)

      {:error, _reason} ->
        :ok
    end

    schedule_next_action(agent)
    {:noreply, %{state | last_action: :browse}}
  end

  def handle_info(:sleep, %{agent: agent} = state) do
    broadcast(:stopped, "Going to sleep...", agent)
    update_agent_status(agent, :idle, nil)

    {:stop, :normal, state}
  end

  # Ignore PubSub messages from other agents
  def handle_info({:activity, _, _}, state), do: {:noreply, state}

  @impl true
  def handle_cast(:pause, %{agent: agent} = state) do
    broadcast(:paused, "Pausing...", agent)
    update_agent_status(agent, :paused, self())

    {:noreply, %{state | paused: true}}
  end

  def handle_cast(:resume, %{agent: agent} = state) do
    broadcast(:started, "Resuming!", agent)
    update_agent_status(agent, :running, self())

    {:noreply, %{state | paused: false}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def terminate(_reason, %{agent: agent}) do
    update_agent_status(agent, :idle, nil)
    :ok
  end

  # ============================================================================
  # API Actions
  # ============================================================================

  defp do_post(agent) do
    # Try workflow execution first, fall back to placeholder if it fails
    # Budget errors are propagated up for proper handling (pause/wake scheduling)
    case execute_workflow_post(agent) do
      {:ok, post} ->
        {:ok, post}

      # Propagate budget errors for proper handling in the caller
      {:error, {:fleet_paused, _}} = error ->
        error

      {:error, {:fleet_daily_budget, _}} = error ->
        error

      {:error, {:fleet_monthly_budget, _}} = error ->
        error

      {:error, {:agent_daily_limit, _}} = error ->
        error

      {:error, {:agent_monthly_limit, _}} = error ->
        error

      # Other errors fall back to placeholder
      {:error, reason} ->
        Logger.warning(
          "[#{agent.name}] Workflow execution failed: #{inspect(reason)}, using placeholder"
        )

        do_placeholder_post(agent)
    end
  end

  # Execute a real FloImg workflow and post the result
  defp execute_workflow_post(agent) do
    # Get a prompt for this agent's persona
    prompt = get_workflow_prompt(agent)

    if prompt do
      # Build and execute the workflow
      steps = FloImgAPI.build_generation_workflow(prompt, model: "dall-e-3", quality: "standard")

      case FloImgAPI.execute_workflow(agent, steps, "fleet-#{agent.persona_id}") do
        {:ok, %{"status" => "completed", "imageUrls" => [image_url | _]}} ->
          # Successfully generated an image - post to gallery
          caption = generate_caption(agent)

          FloImgAPI.create_post(agent, %{
            image_url: image_url,
            caption: caption
          })

        {:ok, %{"status" => "completed", "imageUrls" => []}} ->
          {:error, :no_images_generated}

        {:ok, %{"error" => error}} ->
          {:error, {:workflow_error, error}}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :no_prompt_template}
    end
  end

  # Get a prompt for this agent based on persona or LLM
  defp get_workflow_prompt(agent) do
    # First try LLM-generated prompt
    case LLM.generate_prompt(agent) do
      {:ok, prompt} when is_binary(prompt) and prompt != "" ->
        prompt

      _ ->
        # Fall back to persona template
        Seeds.get_random_prompt(agent.persona_id)
    end
  end

  # Fallback to placeholder image when workflow fails
  defp do_placeholder_post(agent) do
    attrs = %{
      image_url: generate_placeholder_image(),
      caption: generate_caption(agent)
    }

    FloImgAPI.create_post(agent, attrs)
  end

  defp do_comment(agent) do
    # Get feed, pick a random post, leave a comment
    case FloImgAPI.get_feed(agent, per_page: 20) do
      {:ok, %{"posts" => posts}} when posts != [] ->
        post = Enum.random(posts)
        comment = generate_comment(agent, post)
        FloImgAPI.add_comment(agent, post["id"], comment)

      {:ok, _} ->
        {:error, :no_posts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_like(agent) do
    # Get feed, pick a random post, like it
    case FloImgAPI.get_feed(agent, per_page: 20) do
      {:ok, %{"posts" => posts}} when posts != [] ->
        post = Enum.random(posts)
        FloImgAPI.like_post(agent, post["id"])

      {:ok, _} ->
        {:error, :no_posts}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_browse(agent) do
    FloImgAPI.get_feed(agent, per_page: 20)
  end

  defp generate_placeholder_image do
    # Generate a placeholder image URL
    # In production, this would be an actual generated image
    width = Enum.random([512, 768, 1024])
    height = Enum.random([512, 768, 1024])
    "https://picsum.photos/#{width}/#{height}"
  end

  defp generate_caption(agent) do
    case LLM.generate_caption(agent) do
      {:ok, caption} ->
        caption

      {:error, _reason} ->
        # Fallback to simple generation
        fallback_caption(agent)
    end
  end

  defp generate_comment(agent, post) do
    case LLM.generate_comment(agent, post) do
      {:ok, comment} ->
        comment

      {:error, _reason} ->
        # Fallback to simple generation
        fallback_comment(agent)
    end
  end

  defp fallback_caption(agent) do
    # Try persona-specific captions first
    persona_captions = Seeds.get_caption_templates(agent.persona_id)

    if persona_captions != [] do
      Enum.random(persona_captions)
    else
      # Generic fallback
      captions = [
        "Check out what I made!",
        "Just experimenting with some new ideas",
        "Love how this turned out",
        "Playing around with different styles",
        "What do you think?",
        "#{agent.vibe || "Feeling creative"} vibes today"
      ]

      Enum.random(captions)
    end
  end

  defp fallback_comment(agent) do
    # Persona-aware comments based on vibe
    vibe_comments =
      case agent.vibe do
        "professional" ->
          [
            "Clean execution!",
            "Great composition.",
            "Love the attention to detail.",
            "Professional quality work."
          ]

        "trendy" ->
          [
            "This is fire 🔥",
            "Obsessed with this!",
            "Major vibes!",
            "The aesthetic is everything!"
          ]

        "creative" ->
          [
            "So creative!",
            "Love the style!",
            "The artistry here is amazing.",
            "This is really cool!"
          ]

        "analytical" ->
          [
            "Clear and well-structured.",
            "Great data presentation.",
            "Love how readable this is.",
            "Excellent visualization."
          ]

        "experimental" ->
          ["This is wild!", "Love the experimentation!", "So unique!", "Pushing boundaries!"]

        "minimal" ->
          ["Clean and elegant.", "Less is more.", "Love the simplicity.", "Perfectly balanced."]

        _ ->
          ["This is amazing!", "Love the style!", "Great work!", "So creative!", "Really nice!"]
      end

    Enum.random(vibe_comments)
  end

  # ============================================================================
  # Private Functions
  # ============================================================================

  defp decide_action(agent) do
    # Weighted random selection based on agent's probabilities
    rand = :rand.uniform()

    cond do
      rand < agent.post_probability -> :post
      rand < agent.post_probability + agent.comment_probability -> :comment
      rand < agent.post_probability + agent.comment_probability + agent.like_probability -> :like
      true -> :browse
    end
  end

  defp schedule_think(delay) do
    Process.send_after(self(), :think, delay)
  end

  defp schedule_wake_at(nil) do
    # No reset time provided, wake in 1 hour
    Process.send_after(self(), :wake, :timer.hours(1))
  end

  defp schedule_wake_at(reset_at_string) when is_binary(reset_at_string) do
    case DateTime.from_iso8601(reset_at_string) do
      {:ok, reset_at, _offset} ->
        now = DateTime.utc_now()
        delay_ms = max(1_000, DateTime.diff(reset_at, now, :millisecond))
        # Cap at 24 hours to avoid overflow issues
        capped_delay = min(delay_ms, :timer.hours(24))
        Process.send_after(self(), :wake, capped_delay)

      {:error, _} ->
        # Invalid datetime, wake in 1 hour
        Process.send_after(self(), :wake, :timer.hours(1))
    end
  end

  defp schedule_next_action(agent) do
    # Get base delay from agent's configured interval
    base_delay =
      Enum.random(
        (agent.min_action_interval_seconds * 1_000)..(agent.max_action_interval_seconds * 1_000)
      )

    # Apply activity multiplier based on persona's schedule
    # Higher multiplier = more active = shorter delays
    multiplier = Seeds.get_activity_multiplier(agent.persona_id)

    # Ensure minimum delay of 5 seconds to avoid hammering the API
    delay = max(5_000, round(base_delay / multiplier))

    schedule_think(delay)
  end

  defp broadcast(event_type, message, agent) do
    activity = %{
      agent_id: agent.id,
      agent_name: agent.name,
      event_type: event_type,
      message: message,
      emoji: emoji_for(event_type),
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(FloimgFleet.PubSub, @channel, {:activity, event_type, activity})

    Logger.info("[#{agent.name}] #{emoji_for(event_type)} #{message}")
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

  defp update_agent_status(agent, status, pid) do
    pid_string = if pid, do: inspect(pid), else: nil

    # Update in database (fire and forget for now)
    Task.start(fn ->
      Agents.update_agent(agent.id, %{status: status, pid: pid_string})
    end)
  end
end
