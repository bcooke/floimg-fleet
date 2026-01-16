defmodule FloimgFleet.Bots.Schemas.Bot do
  @moduledoc """
  Schema for a bot configuration.

  Bots are persisted configurations that define personality, behavior,
  and settings. Runtime state is managed by GenServer processes.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses [:idle, :running, :paused, :error]

  schema "bots" do
    field :name, :string
    field :username, :string
    field :status, Ecto.Enum, values: @statuses, default: :idle

    # Personality traits (LLM-generated or configured)
    field :personality, :string
    field :vibe, :string
    field :interests, {:array, :string}, default: []

    # Behavior configuration
    field :post_probability, :float, default: 0.3
    field :comment_probability, :float, default: 0.4
    field :like_probability, :float, default: 0.5
    field :min_action_interval_seconds, :integer, default: 60
    field :max_action_interval_seconds, :integer, default: 300

    # Runtime tracking (denormalized for quick queries)
    field :pid, :string
    field :last_action_at, :utc_datetime
    field :total_posts, :integer, default: 0
    field :total_comments, :integer, default: 0
    field :total_likes, :integer, default: 0

    # Soft delete
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name, :username]
  @optional_fields [
    :personality,
    :vibe,
    :interests,
    :post_probability,
    :comment_probability,
    :like_probability,
    :min_action_interval_seconds,
    :max_action_interval_seconds,
    :status,
    :pid,
    :last_action_at,
    :total_posts,
    :total_comments,
    :total_likes,
    :deleted_at
  ]

  def changeset(bot, attrs) do
    bot
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:username, min: 3, max: 30)
    |> validate_number(:post_probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:comment_probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:like_probability, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    |> validate_number(:min_action_interval_seconds, greater_than: 0)
    |> validate_number(:max_action_interval_seconds, greater_than: 0)
    |> validate_intervals()
    |> unique_constraint(:username)
  end

  defp validate_intervals(changeset) do
    min = get_field(changeset, :min_action_interval_seconds)
    max = get_field(changeset, :max_action_interval_seconds)

    if min && max && min > max do
      add_error(changeset, :min_action_interval_seconds, "must be less than max interval")
    else
      changeset
    end
  end

  # Convenience functions

  def active?(bot), do: is_nil(bot.deleted_at)
  def running?(bot), do: bot.status == :running
  def paused?(bot), do: bot.status == :paused
end
