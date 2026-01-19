defmodule FloimgFleet.Agents.Commands.StartAgent do
  @moduledoc """
  Command to start an agent.
  """

  alias FloimgFleet.Agents.Queries.GetAgent
  alias FloimgFleet.Runtime.AgentSupervisor

  defstruct [:agent_id]

  @type t :: %__MODULE__{agent_id: String.t()}

  @spec execute(t()) :: {:ok, pid()} | {:error, term()}
  def execute(%__MODULE__{agent_id: agent_id}) do
    case GetAgent.execute(agent_id) do
      {:ok, agent} ->
        AgentSupervisor.start_agent(agent)

      {:error, _} = error ->
        error
    end
  end
end
