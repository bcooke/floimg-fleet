defmodule FloimgFleetWeb.BotLive.FormComponent do
  use FloimgFleetWeb, :live_component

  alias FloimgFleet.Bots
  alias FloimgFleet.Bots.Schemas.Bot

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-xl font-bold mb-4">{@title}</h2>

      <.form for={@form} id="bot-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Name</span>
            </label>
            <input
              type="text"
              name={@form[:name].name}
              value={@form[:name].value}
              class={["input input-bordered", @form[:name].errors != [] && "input-error"]}
              placeholder="Bot name"
            />
            <label :if={@form[:name].errors != []} class="label">
              <span class="label-text-alt text-error">
                {Enum.map_join(@form[:name].errors, ", ", &translate_error/1)}
              </span>
            </label>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Username</span>
            </label>
            <input
              type="text"
              name={@form[:username].name}
              value={@form[:username].value}
              class={["input input-bordered", @form[:username].errors != [] && "input-error"]}
              placeholder="@username"
            />
            <label :if={@form[:username].errors != []} class="label">
              <span class="label-text-alt text-error">
                {Enum.map_join(@form[:username].errors, ", ", &translate_error/1)}
              </span>
            </label>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Personality</span>
            </label>
            <textarea
              name={@form[:personality].name}
              class="textarea textarea-bordered"
              placeholder="Describe the bot's personality..."
              rows="3"
            >{@form[:personality].value}</textarea>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Vibe</span>
            </label>
            <input
              type="text"
              name={@form[:vibe].name}
              value={@form[:vibe].value}
              class="input input-bordered"
              placeholder="e.g., chill, enthusiastic, professional"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Interests</span>
            </label>
            <input
              type="text"
              name={@form[:interests].name}
              value={interests_to_string(@form[:interests].value)}
              class="input input-bordered"
              placeholder="e.g., photography, travel, nature (comma-separated)"
            />
            <label class="label">
              <span class="label-text-alt text-base-content/60">Separate interests with commas</span>
            </label>
          </div>

          <div class="divider">Behavior Settings</div>

          <div class="grid grid-cols-3 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Post %</span>
              </label>
              <input
                type="number"
                name={@form[:post_probability].name}
                value={to_percent(@form[:post_probability].value)}
                min="0"
                max="100"
                step="5"
                class="input input-bordered"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Comment %</span>
              </label>
              <input
                type="number"
                name={@form[:comment_probability].name}
                value={to_percent(@form[:comment_probability].value)}
                min="0"
                max="100"
                step="5"
                class="input input-bordered"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Like %</span>
              </label>
              <input
                type="number"
                name={@form[:like_probability].name}
                value={to_percent(@form[:like_probability].value)}
                min="0"
                max="100"
                step="5"
                class="input input-bordered"
              />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Min Interval (seconds)</span>
              </label>
              <input
                type="number"
                name={@form[:min_action_interval_seconds].name}
                value={@form[:min_action_interval_seconds].value}
                min="10"
                max="3600"
                class="input input-bordered"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Max Interval (seconds)</span>
              </label>
              <input
                type="number"
                name={@form[:max_action_interval_seconds].name}
                value={@form[:max_action_interval_seconds].value}
                min="10"
                max="3600"
                class="input input-bordered"
              />
            </div>
          </div>
        </div>

        <div class="modal-action">
          <.link navigate={@navigate} class="btn btn-ghost">Cancel</.link>
          <button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
            Save Bot
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{bot: bot} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Bot.changeset(bot, %{}))
     end)}
  end

  @impl true
  def handle_event("validate", %{"bot" => bot_params}, socket) do
    bot_params = normalize_params(bot_params)

    changeset =
      socket.assigns.bot
      |> Bot.changeset(bot_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"bot" => bot_params}, socket) do
    bot_params = normalize_params(bot_params)
    save_bot(socket, socket.assigns.action, bot_params)
  end

  defp save_bot(socket, :edit, bot_params) do
    case Bots.update_bot(socket.assigns.bot.id, bot_params) do
      {:ok, _bot} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bot updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bot(socket, :new, bot_params) do
    case Bots.create_bot(bot_params) do
      {:ok, _bot} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bot created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp normalize_params(params) do
    params
    |> Map.update("post_probability", nil, &from_percent/1)
    |> Map.update("comment_probability", nil, &from_percent/1)
    |> Map.update("like_probability", nil, &from_percent/1)
    |> Map.update("interests", nil, &parse_interests/1)
  end

  defp to_percent(nil), do: 0
  defp to_percent(value) when is_float(value), do: round(value * 100)
  defp to_percent(value) when is_integer(value), do: value
  defp to_percent(value) when is_binary(value), do: to_percent(String.to_float(value))

  defp from_percent(nil), do: nil
  defp from_percent(""), do: nil
  defp from_percent(value) when is_binary(value), do: String.to_integer(value) / 100
  defp from_percent(value) when is_integer(value), do: value / 100

  defp interests_to_string(nil), do: ""
  defp interests_to_string(interests) when is_list(interests), do: Enum.join(interests, ", ")
  defp interests_to_string(interests), do: interests

  defp parse_interests(nil), do: []
  defp parse_interests(""), do: []

  defp parse_interests(value) when is_binary(value) do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_interests(value) when is_list(value), do: value
end
