defmodule FloimgFleetWeb.AgentLive.Show do
  use FloimgFleetWeb, :live_view

  alias FloimgFleet.Agents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FloimgFleet.PubSub, "fleet:activity")
    end

    case Agents.get_agent(id) do
      {:ok, bot} ->
        activities = Agents.get_activity(%{agent_id: id, limit: 50})

        {:ok,
         socket
         |> assign(:page_title, bot.name)
         |> assign(:bot, bot)
         |> stream(:activities, activities, at: 0)}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Bot not found")
         |> push_navigate(to: ~p"/bots")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, id)}
  end

  defp apply_action(socket, :show, _id) do
    socket
  end

  defp apply_action(socket, :edit, _id) do
    socket
    |> assign(:page_title, "Edit #{socket.assigns.bot.name}")
  end

  @impl true
  def handle_info({:agent_activity, activity}, socket) do
    if activity.agent_id == socket.assigns.bot.id do
      {:noreply, stream_insert(socket, :activities, activity, at: 0)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:bot_updated, bot}, socket) do
    if bot.id == socket.assigns.bot.id do
      {:noreply, assign(socket, :bot, bot)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl true
  def handle_event("start", _params, socket) do
    case Agents.start_agent(socket.assigns.bot.id) do
      {:ok, bot} ->
        {:noreply,
         socket
         |> assign(:bot, bot)
         |> put_flash(:info, "Bot started")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to start: #{reason}")}
    end
  end

  def handle_event("pause", _params, socket) do
    case Agents.pause_agent(socket.assigns.bot.id) do
      {:ok, bot} ->
        {:noreply,
         socket
         |> assign(:bot, bot)
         |> put_flash(:info, "Bot paused")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to pause: #{reason}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="mb-6">
        <.link navigate={~p"/bots"} class="btn btn-ghost btn-sm gap-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Back to Bots
        </.link>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2">
          <div class="card bg-base-200">
            <div class="card-body">
              <div class="flex justify-between items-start">
                <div>
                  <h1 class="card-title text-2xl">{@bot.name}</h1>
                  <p class="text-base-content/60">@{@bot.username}</p>
                </div>
                <div class="flex gap-2">
                  <%= if @bot.status in [:idle, :paused] do %>
                    <button phx-click="start" class="btn btn-success btn-sm">Start</button>
                  <% end %>
                  <%= if @bot.status == :running do %>
                    <button phx-click="pause" class="btn btn-warning btn-sm">Pause</button>
                  <% end %>
                  <.link navigate={~p"/bots/#{@bot.id}/edit"} class="btn btn-ghost btn-sm">
                    Edit
                  </.link>
                </div>
              </div>

              <div class="divider"></div>

              <div class="grid grid-cols-2 gap-4">
                <div>
                  <h3 class="font-semibold mb-2">Status</h3>
                  <span class={["badge", status_badge_class(@bot.status)]}>
                    {@bot.status}
                  </span>
                </div>
                <div>
                  <h3 class="font-semibold mb-2">Last Action</h3>
                  <span class="text-base-content/60">
                    {format_time(@bot.last_action_at)}
                  </span>
                </div>
              </div>

              <div class="divider"></div>

              <div>
                <h3 class="font-semibold mb-2">Personality</h3>
                <p class="text-base-content/80">{@bot.personality || "Not set"}</p>
              </div>

              <div class="mt-4">
                <h3 class="font-semibold mb-2">Vibe</h3>
                <p class="text-base-content/80">{@bot.vibe || "Not set"}</p>
              </div>

              <div class="mt-4">
                <h3 class="font-semibold mb-2">Interests</h3>
                <div class="flex flex-wrap gap-2">
                  <%= for interest <- @bot.interests || [] do %>
                    <span class="badge badge-outline">{interest}</span>
                  <% end %>
                  <%= if Enum.empty?(@bot.interests || []) do %>
                    <span class="text-base-content/60">None set</span>
                  <% end %>
                </div>
              </div>

              <div class="divider"></div>

              <h3 class="font-semibold mb-4">Behavior Settings</h3>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div class="stat bg-base-300 rounded-lg p-4">
                  <div class="stat-title text-xs">Post Chance</div>
                  <div class="stat-value text-lg">{percent(@bot.post_probability)}</div>
                </div>
                <div class="stat bg-base-300 rounded-lg p-4">
                  <div class="stat-title text-xs">Comment Chance</div>
                  <div class="stat-value text-lg">{percent(@bot.comment_probability)}</div>
                </div>
                <div class="stat bg-base-300 rounded-lg p-4">
                  <div class="stat-title text-xs">Like Chance</div>
                  <div class="stat-value text-lg">{percent(@bot.like_probability)}</div>
                </div>
                <div class="stat bg-base-300 rounded-lg p-4">
                  <div class="stat-title text-xs">Action Interval</div>
                  <div class="stat-value text-lg">
                    {@bot.min_action_interval_seconds}-{@bot.max_action_interval_seconds}s
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="lg:col-span-1">
          <div class="card bg-base-200">
            <div class="card-body">
              <h2 class="card-title">Activity History</h2>
              <div class="space-y-2 max-h-[500px] overflow-y-auto" id="activities" phx-update="stream">
                <div
                  :for={{dom_id, activity} <- @streams.activities}
                  id={dom_id}
                  class="text-sm p-2 bg-base-300 rounded"
                >
                  <span class="font-medium">{activity.action}</span>
                  <%= if activity.details do %>
                    <p class="text-base-content/60 text-xs mt-1">{activity.details}</p>
                  <% end %>
                  <div class="text-xs text-base-content/40 mt-1">
                    {format_datetime(activity.inserted_at)}
                  </div>
                </div>
                <div
                  :if={Enum.empty?(@streams.activities)}
                  class="text-center text-base-content/60 py-4"
                >
                  No activity yet
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <.modal
      :if={@live_action == :edit}
      id="bot-modal"
      show
      on_cancel={JS.navigate(~p"/bots/#{@bot.id}")}
    >
      <.live_component
        module={FloimgFleetWeb.AgentLive.FormComponent}
        id={@bot.id}
        title={@page_title}
        action={@live_action}
        bot={@bot}
        navigate={~p"/bots/#{@bot.id}"}
      />
    </.modal>
    """
  end

  defp status_badge_class(:idle), do: "badge-ghost"
  defp status_badge_class(:running), do: "badge-success"
  defp status_badge_class(:paused), do: "badge-warning"
  defp status_badge_class(:error), do: "badge-error"
  defp status_badge_class(_), do: "badge-ghost"

  defp format_time(nil), do: "Never"
  defp format_time(datetime), do: Calendar.strftime(datetime, "%H:%M:%S")

  defp format_datetime(nil), do: "Never"
  defp format_datetime(datetime), do: Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")

  defp percent(nil), do: "0%"
  defp percent(value), do: "#{round(value * 100)}%"
end
