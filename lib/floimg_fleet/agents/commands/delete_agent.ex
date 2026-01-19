defmodule FloimgFleet.Agents.Commands.DeleteAgent do
  @moduledoc """
  Command to soft-delete a bot.
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
      {:ok, bot} ->
        # Stop the bot if running
        if bot.pid do
          AgentSupervisor.stop_agent(bot.pid)
        end

        # Soft delete
        bot
        |> Agent.changeset(%{deleted_at: DateTime.utc_now(), status: :idle, pid: nil})
        |> Repo.update()

      {:error, _} = error ->
        error
    end
  end
end
