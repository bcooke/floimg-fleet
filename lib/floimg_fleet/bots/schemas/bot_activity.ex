defmodule FloimgFleet.Bots.Schemas.BotActivity do
  @moduledoc """
  Schema for bot activity logs.

  Records every action a bot takes for analytics, debugging,
  and real-time activity feeds.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @event_types [:thought, :action, :post, :comment, :like, :error, :started, :paused, :stopped]

  schema "bot_activities" do
    belongs_to(:bot, FloimgFleet.Bots.Schemas.Bot)

    field(:event_type, Ecto.Enum, values: @event_types)
    field(:message, :string)
    field(:emoji, :string)

    # Optional metadata (e.g., post_id, target_user, etc.)
    field(:metadata, :map, default: %{})

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_fields [:bot_id, :event_type, :message]
  @optional_fields [:emoji, :metadata]

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:message, max: 1000)
    |> foreign_key_constraint(:bot_id)
  end
end
