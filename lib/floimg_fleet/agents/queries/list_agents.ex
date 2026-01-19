defmodule FloimgFleet.Agents.Queries.ListAgents do
  @moduledoc """
  Query to list bots with filtering and pagination.

  ## Examples

      iex> execute(%{status: :running})
      [%Agent{status: :running}, ...]

      iex> execute(%{page: 1, per_page: 10})
      %{entries: [...], total_count: 42}

  """

  import Ecto.Query
  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.Agent

  @type params :: %{
          optional(:status) => atom(),
          optional(:page) => pos_integer(),
          optional(:per_page) => pos_integer(),
          optional(:include_deleted) => boolean()
        }

  @spec execute(params()) :: [Agent.t()] | %{entries: [Agent.t()], total_count: non_neg_integer()}
  def execute(params \\ %{}) do
    query =
      Bot
      |> maybe_filter_status(params)
      |> maybe_exclude_deleted(params)
      |> order_by([b], desc: b.inserted_at)

    if Map.has_key?(params, :page) do
      paginate(query, params)
    else
      Repo.all(query)
    end
  end

  defp maybe_filter_status(query, %{status: status}) when not is_nil(status) do
    where(query, [b], b.status == ^status)
  end

  defp maybe_filter_status(query, _), do: query

  defp maybe_exclude_deleted(query, %{include_deleted: true}), do: query

  defp maybe_exclude_deleted(query, _) do
    where(query, [b], is_nil(b.deleted_at))
  end

  defp paginate(query, params) do
    page = Map.get(params, :page, 1)
    per_page = Map.get(params, :per_page, 20)
    offset = (page - 1) * per_page

    entries =
      query
      |> limit(^per_page)
      |> offset(^offset)
      |> Repo.all()

    total_count = Repo.aggregate(query, :count, :id)

    %{entries: entries, total_count: total_count}
  end
end
