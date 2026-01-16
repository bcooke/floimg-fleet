defmodule FloimgFleet.Bots.Queries.GetBot do
  @moduledoc """
  Query to get a single bot by ID.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Bots.Schemas.Bot

  @spec execute(String.t()) :: {:ok, Bot.t()} | {:error, :not_found}
  def execute(id) do
    case Repo.get(Bot, id) do
      nil -> {:error, :not_found}
      bot -> {:ok, bot}
    end
  end

  @spec execute!(String.t()) :: Bot.t()
  def execute!(id) do
    Repo.get!(Bot, id)
  end
end
