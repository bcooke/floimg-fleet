defmodule FloimgFleet.Agents.Queries.GetAgent do
  @moduledoc """
  Query to get a single bot by ID.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.Agent

  @spec execute(String.t()) :: {:ok, Agent.t()} | {:error, :not_found}
  def execute(id) do
    case Repo.get(Bot, id) do
      nil -> {:error, :not_found}
      bot -> {:ok, bot}
    end
  end

  @spec execute!(String.t()) :: Agent.t()
  def execute!(id) do
    Repo.get!(Bot, id)
  end
end
