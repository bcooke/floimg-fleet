defmodule FloimgFleet.Agents.Commands.StartAgent do
  @moduledoc """
  Command to start a bot agent.
  """

  alias FloimgFleet.Agents.Queries.GetAgent
  alias FloimgFleet.Runtime.AgentSupervisor

  defstruct [:agent_id]

  @type t :: %__MODULE__{agent_id: String.t()}

  @spec execute(t()) :: {:ok, pid()} | {:error, term()}
  def execute(%__MODULE__{agent_id: agent_id}) do
    case GetAgent.execute(agent_id) do
      {:ok, bot} ->
        AgentSupervisor.start_agent(bot)

      {:error, _} = error ->
        error
    end
  end
end
