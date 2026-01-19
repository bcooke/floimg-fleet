defmodule FloimgFleet.Bots.Commands.PauseAll do
  @moduledoc """
  Command to pause all running bots.
  """

  alias FloimgFleet.Runtime.BotSupervisor
  alias FloimgFleet.Runtime.BotAgent

  defstruct []

  @type t :: %__MODULE__{}

  @spec execute(t()) :: {:ok, non_neg_integer()}
  def execute(%__MODULE__{}) do
    pids = BotSupervisor.list_children()

    for pid <- pids do
      BotAgent.pause(pid)
    end

    {:ok, length(pids)}
  end
end
