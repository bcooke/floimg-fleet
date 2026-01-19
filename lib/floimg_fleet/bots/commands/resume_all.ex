defmodule FloimgFleet.Bots.Commands.ResumeAll do
  @moduledoc """
  Command to start/resume all bots.

  Starts bots from the database that aren't running yet,
  and resumes any that are paused.
  """

  alias FloimgFleet.Bots.Queries.ListBots
  alias FloimgFleet.Runtime.BotSupervisor
  alias FloimgFleet.Runtime.BotAgent

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, non_neg_integer()}
  def execute(%__MODULE__{}) do
    # Get all bots from DB
    bots = ListBots.execute(%{})

    # Get currently running PIDs
    running_pids = BotSupervisor.list_children()

    # Resume already running bots
    for pid <- running_pids do
      BotAgent.resume(pid)
    end

    # Start bots that aren't running
    # We track bot IDs via the GenServer state, so we start all bots
    # and let the supervisor handle duplicates
    started_count =
      bots
      |> Enum.reduce(0, fn bot, count ->
        case BotSupervisor.start_bot(bot) do
          {:ok, _pid} -> count + 1
          {:error, {:already_started, _}} -> count
          {:error, _} -> count
        end
      end)

    {:ok, length(running_pids) + started_count}
  end
end
