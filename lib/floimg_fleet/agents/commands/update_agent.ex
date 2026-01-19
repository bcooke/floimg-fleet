defmodule FloimgFleet.Agents.Commands.UpdateAgent do
  @moduledoc """
  Command to update an existing agent.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.Agent
  alias FloimgFleet.Agents.Queries.GetAgent

  defstruct [
    :agent_id,
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

  @spec execute(t()) :: {:ok, Agent.t()} | {:error, term()}
  def execute(%__MODULE__{agent_id: agent_id} = command) do
    case GetAgent.execute(agent_id) do
      {:ok, agent} ->
        attrs =
          command
          |> Map.from_struct()
          |> Map.delete(:agent_id)
          |> Enum.reject(fn {_, v} -> is_nil(v) end)
          |> Map.new()

        agent
        |> Agent.changeset(attrs)
        |> Repo.update()

      {:error, _} = error ->
        error
    end
  end
end
