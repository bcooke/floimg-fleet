defmodule FloimgFleet.Agents.Commands.ResumeAll do
  @moduledoc """
  Command to start/resume all bots.

  Starts bots from the database that aren't running yet,
  and resumes any that are paused.
  """

  alias FloimgFleet.Agents.Queries.ListAgents
  alias FloimgFleet.Runtime.AgentSupervisor
  alias FloimgFleet.Runtime.AgentWorker

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, non_neg_integer()}
  def execute(%__MODULE__{}) do
    # Get all bots from DB
    bots = ListAgents.execute(%{})

    # Get currently running PIDs
    running_pids = AgentSupervisor.list_children()

    # Resume already running bots
    for pid <- running_pids do
      AgentWorker.resume(pid)
    end

    # Start bots that aren't running
    # We track bot IDs via the GenServer state, so we start all bots
    # and let the supervisor handle duplicates
    started_count =
      bots
      |> Enum.reduce(0, fn bot, count ->
        case AgentSupervisor.start_agent(bot) do
          {:ok, _pid} -> count + 1
          {:error, {:already_started, _}} -> count
          {:error, _} -> count
        end
      end)

    {:ok, length(running_pids) + started_count}
  end
end
