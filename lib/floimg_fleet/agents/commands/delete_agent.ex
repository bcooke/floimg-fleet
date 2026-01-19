defmodule FloimgFleet.Agents.Commands.DeleteAgent do
  @moduledoc """
  Command to soft-delete an agent.
  """

  alias FloimgFleet.Repo
  alias FloimgFleet.Agents.Schemas.Agent
  alias FloimgFleet.Agents.Queries.GetAgent
  alias FloimgFleet.Runtime.AgentSupervisor

  defstruct [:agent_id]

  @type t :: %__MODULE__{agent_id: String.t()}

  @spec execute(t()) :: {:ok, Agent.t()} | {:error, term()}
  def execute(%__MODULE__{agent_id: agent_id}) do
    case GetAgent.execute(agent_id) do
      {:ok, agent} ->
        # Stop the agent if running
        if agent.pid do
          AgentSupervisor.stop_agent(agent.pid)
        end

        # Soft delete
        agent
        |> Agent.changeset(%{deleted_at: DateTime.utc_now(), status: :idle, pid: nil})
        |> Repo.update()

      {:error, _} = error ->
        error
    end
  end
end
