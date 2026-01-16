defmodule FloimgFleet.Bots.Queries.GetActivity do
  @moduledoc """
  Query to get bot activity logs.
  """

  import Ecto.Query
  alias FloimgFleet.Repo
  alias FloimgFleet.Bots.Schemas.BotActivity

  @type params :: %{
          optional(:bot_id) => String.t(),
          optional(:event_type) => atom(),
          optional(:limit) => pos_integer(),
          optional(:since) => DateTime.t()
        }

  @spec execute(params()) :: [BotActivity.t()]
  def execute(params \\ %{}) do
    limit = Map.get(params, :limit, 50)

    BotActivity
    |> maybe_filter_bot(params)
    |> maybe_filter_event_type(params)
    |> maybe_filter_since(params)
    |> order_by([a], desc: a.inserted_at)
    |> limit(^limit)
    |> preload(:bot)
    |> Repo.all()
  end

  defp maybe_filter_bot(query, %{bot_id: bot_id}) when not is_nil(bot_id) do
    where(query, [a], a.bot_id == ^bot_id)
  end

  defp maybe_filter_bot(query, _), do: query

  defp maybe_filter_event_type(query, %{event_type: event_type}) when not is_nil(event_type) do
    where(query, [a], a.event_type == ^event_type)
  end

  defp maybe_filter_event_type(query, _), do: query

  defp maybe_filter_since(query, %{since: since}) when not is_nil(since) do
    where(query, [a], a.inserted_at >= ^since)
  end

  defp maybe_filter_since(query, _), do: query
end
