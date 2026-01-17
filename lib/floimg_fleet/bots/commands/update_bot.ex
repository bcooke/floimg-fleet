defmodule FloimgFleet.Bots.Commands.UpdateBot do
  @moduledoc """
  Command to update an existing bot.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Bots.Schemas.Bot
  alias FloimgFleet.Bots.Queries.GetBot

  defstruct [
    :bot_id,
    :name,
    :username,
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
    :last_action_at
  ]

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, Bot.t()} | {:error, term()}
  def execute(%__MODULE__{bot_id: bot_id} = command) do
    case GetBot.execute(bot_id) do
      {:ok, bot} ->
        attrs =
          command
          |> Map.from_struct()
          |> Map.delete(:bot_id)
          |> Enum.reject(fn {_, v} -> is_nil(v) end)
          |> Map.new()

        bot
        |> Bot.changeset(attrs)
        |> Repo.update()

      {:error, _} = error ->
        error
    end
  end
end
