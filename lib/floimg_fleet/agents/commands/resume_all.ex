defmodule FloimgFleet.Agents.Commands.ResumeAll do
  @moduledoc """
  Command to start/resume all agents.

  Starts agents from the database that aren't running yet,
  and resumes any that are paused.
  """

  alias FloimgFleet.Agents.Queries.ListAgents
  alias FloimgFleet.Runtime.AgentSupervisor
  alias FloimgFleet.Runtime.AgentWorker

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, non_neg_integer()}
  def execute(%__MODULE__{}) do
    # Get all agents from DB
    agents = ListAgents.execute(%{})

    # Get currently running PIDs
    running_pids = AgentSupervisor.list_children()

    # Resume already running agents
    for pid <- running_pids do
      AgentWorker.resume(pid)
    end

    # Start agents that aren't running
    # We track agent IDs via the GenServer state, so we start all agents
    # and let the supervisor handle duplicates
    started_count =
      agents
      |> Enum.reduce(0, fn agent, count ->
        case AgentSupervisor.start_agent(agent) do
          {:ok, _pid} -> count + 1
          {:error, {:already_started, _}} -> count
          {:error, _} -> count
        end
      end)

    {:ok, length(running_pids) + started_count}
  end
end
