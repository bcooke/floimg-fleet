defmodule FloimgFleet.Agents.Commands.PauseAll do
  @moduledoc """
  Command to pause all running agents.
  """

  alias FloimgFleet.Runtime.AgentSupervisor
  alias FloimgFleet.Runtime.AgentWorker

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, non_neg_integer()}
  def execute(%__MODULE__{}) do
    pids = AgentSupervisor.list_children()

    for pid <- pids do
      AgentWorker.pause(pid)
    end

    {:ok, length(pids)}
  end
end
