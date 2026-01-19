defmodule FloimgFleet.Agents.Queries.GetActivity do
  @moduledoc """
  Query to get agent activity logs.
  """

  import Ecto.Query
  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.AgentActivity

  @type params :: %{
          optional(:agent_id) => String.t(),
          optional(:event_type) => atom(),
          optional(:limit) => pos_integer(),
          optional(:since) => DateTime.t()
        }

  @spec execute(params()) :: [AgentActivity.t()]
  def execute(params \\ %{}) do
    limit = Map.get(params, :limit, 50)

    AgentActivity
    |> maybe_filter_agent(params)
    |> maybe_filter_event_type(params)
    |> maybe_filter_since(params)
    |> order_by([a], desc: a.inserted_at)
    |> limit(^limit)
    |> preload(:agent)
    |> Repo.all()
  end

  defp maybe_filter_agent(query, %{agent_id: agent_id}) when not is_nil(agent_id) do
    where(query, [a], a.agent_id == ^agent_id)
  end

  defp maybe_filter_agent(query, _), do: query

  defp maybe_filter_event_type(query, %{event_type: event_type}) when not is_nil(event_type) do
    where(query, [a], a.event_type == ^event_type)
  end

  defp maybe_filter_event_type(query, _), do: query

  defp maybe_filter_since(query, %{since: since}) when not is_nil(since) do
    where(query, [a], a.inserted_at >= ^since)
  end

  defp maybe_filter_since(query, _), do: query
end
