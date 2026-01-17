defmodule FloimgFleetWeb.BotLive.Index do
  use FloimgFleetWeb, :live_view

  alias FloimgFleet.Bots
  alias FloimgFleet.Bots.Schemas.Bot

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FloimgFleet.PubSub, "fleet:activity")
    end

    {:ok,
     socket
     |> assign(:page_title, "Bots")
     |> assign(:activities_empty, true)
     |> stream(:bots, Bots.list_bots())
     |> stream(:activities, [], at: 0)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Bots")
    |> assign(:bot, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Bot")
    |> assign(:bot, %Bot{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Bots.get_bot(id) do
      {:ok, bot} ->
        socket
        |> assign(:page_title, "Edit #{bot.name}")
        |> assign(:bot, bot)

      {:error, :not_found} ->
        socket
        |> put_flash(:error, "Bot not found")
        |> push_navigate(to: ~p"/bots")
    end
  end

  @impl true
  def handle_info({:bot_activity, activity}, socket) do
    {:noreply,
     socket
     |> assign(:activities_empty, false)
     |> stream_insert(:activities, activity, at: 0)}
  end

  def handle_info({:bot_started, bot}, socket) do
    {:noreply, stream_insert(socket, :bots, bot)}
  end

  def handle_info({:bot_stopped, bot}, socket) do
    {:noreply, stream_insert(socket, :bots, bot)}
  end

  def handle_info({:bot_updated, bot}, socket) do
    {:noreply, stream_insert(socket, :bots, bot)}
  end

  @impl true
  def handle_event("start", %{"id" => id}, socket) do
    case Bots.start_bot(id) do
      {:ok, bot} ->
        {:noreply,
         socket
         |> stream_insert(:bots, bot)
         |> put_flash(:info, "Bot #{bot.name} started")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to start bot: #{reason}")}
    end
  end

  def handle_event("pause", %{"id" => id}, socket) do
    case Bots.pause_bot(id) do
      {:ok, bot} ->
        {:noreply,
         socket
         |> stream_insert(:bots, bot)
         |> put_flash(:info, "Bot #{bot.name} paused")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to pause bot: #{reason}")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Bots.delete_bot(id) do
      {:ok, bot} ->
        {:noreply,
         socket
         |> stream_delete(:bots, bot)
         |> put_flash(:info, "Bot #{bot.name} deleted")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to delete bot: #{reason}")}
    end
  end

  def handle_event("pause_all", _params, socket) do
    case Bots.pause_all() do
      {:ok, count} ->
        {:noreply,
         socket
         |> stream(:bots, Bots.list_bots(), reset: true)
         |> put_flash(:info, "Paused #{count} bots")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to pause all: #{reason}")}
    end
  end

  def handle_event("resume_all", _params, socket) do
    case Bots.resume_all() do
      {:ok, count} ->
        {:noreply,
         socket
         |> stream(:bots, Bots.list_bots(), reset: true)
         |> put_flash(:info, "Resumed #{count} bots")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to resume all: #{reason}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Bot Fleet</h1>
        <div class="flex gap-2">
          <button phx-click="pause_all" class="btn btn-warning btn-sm">
            Pause All
          </button>
          <button phx-click="resume_all" class="btn btn-success btn-sm">
            Resume All
          </button>
          <.link navigate={~p"/bots/new"} class="btn btn-primary btn-sm">
            New Bot
          </.link>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div class="lg:col-span-2">
          <div class="card bg-base-200">
            <div class="card-body">
              <h2 class="card-title">Bots</h2>
              <div class="overflow-x-auto">
                <table class="table table-zebra">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Username</th>
                      <th>Status</th>
                      <th>Last Action</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody id="bots" phx-update="stream">
                    <tr :for={{dom_id, bot} <- @streams.bots} id={dom_id}>
                      <td>
                        <.link navigate={~p"/bots/#{bot.id}"} class="link link-hover">
                          {bot.name}
                        </.link>
                      </td>
                      <td>{bot.username}</td>
                      <td>
                        <.status_badge status={bot.status} />
                      </td>
                      <td class="text-sm text-base-content/60">
                        {format_time(bot.last_action_at)}
                      </td>
                      <td>
                        <div class="flex gap-1">
                          <%= if bot.status in [:idle, :paused] do %>
                            <button
                              phx-click="start"
                              phx-value-id={bot.id}
                              class="btn btn-success btn-xs"
                            >
                              Start
                            </button>
                          <% end %>
                          <%= if bot.status == :running do %>
                            <button
                              phx-click="pause"
                              phx-value-id={bot.id}
                              class="btn btn-warning btn-xs"
                            >
                              Pause
                            </button>
                          <% end %>
                          <.link navigate={~p"/bots/#{bot.id}/edit"} class="btn btn-ghost btn-xs">
                            Edit
                          </.link>
                          <button
                            phx-click="delete"
                            phx-value-id={bot.id}
                            data-confirm="Are you sure you want to delete this bot?"
                            class="btn btn-error btn-xs"
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <div class="lg:col-span-1">
          <div class="card bg-base-200">
            <div class="card-body">
              <h2 class="card-title">Activity Feed</h2>
              <div class="space-y-2 max-h-96 overflow-y-auto" id="activities" phx-update="stream">
                <div
                  :for={{dom_id, activity} <- @streams.activities}
                  id={dom_id}
                  class="text-sm p-2 bg-base-300 rounded"
                >
                  <span class="font-medium">{activity.bot_name || "Bot"}</span>
                  <span class="text-base-content/60">{activity.action}</span>
                  <div class="text-xs text-base-content/40">
                    {format_time(activity.inserted_at)}
                  </div>
                </div>
                <div :if={@activities_empty} class="text-center text-base-content/60 py-4">
                  No activity yet
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <.modal :if={@live_action in [:new, :edit]} id="bot-modal" show on_cancel={JS.navigate(~p"/bots")}>
      <.live_component
        module={FloimgFleetWeb.BotLive.FormComponent}
        id={@bot.id || :new}
        title={@page_title}
        action={@live_action}
        bot={@bot}
        navigate={~p"/bots"}
      />
    </.modal>
    """
  end

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "badge",
      status_badge_class(@status)
    ]}>
      {@status}
    </span>
    """
  end

  defp status_badge_class(:idle), do: "badge-ghost"
  defp status_badge_class(:running), do: "badge-success"
  defp status_badge_class(:paused), do: "badge-warning"
  defp status_badge_class(:error), do: "badge-error"
  defp status_badge_class(_), do: "badge-ghost"

  defp format_time(nil), do: "Never"

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end
end
